import threading
import logging
import psycopg2
import dejimautils
import os
import json
import requests

# params_dict for execution thread for base table
# "sql_statements" : sql statements for base table
#
# params_dict for execution thread for dejima view
# "update_json" : update contents for dejima view. json format str.

class ExecutionThread(threading.Thread):
    def __init__(self, conn, lock):
        threading.Thread.__init__(self)
        self.conn = conn
        self.lock = lock

    def run(self):
        logging.info("ExecutionThread : start")
        req = self.conn.recv(1024).decode()
        logging.info("request : {}".format(req))
        header, message_body = req.split("\r\n\r\n")
        url = header.split()[1]
        params_dict = json.loads(message_body)

        my_peer_name = os.environ['PEER_NAME']


        with psycopg2.connect("dbname=postgres user=dejima password=barfoo host={}-postgres port=5432".format(my_peer_name)) as db_conn:
            with db_conn.cursor() as cur:
                # note : in psycopg2, transaction is valid as default, so no need to exec "BEGIN;"

                # phase1 : execute update for certain dejima view
                try:
                    if url == "/exec_transaction" :
                        if self.lock["lock"] == True:
                            self.conn.send("HTTP/1.1 423 Locked".encode())
                            self.conn.close()
                            exit()
                        else:
                            self.lock["lock"] = True
                            self.lock["holder"] = my_peer_name

                        result = dejimautils.global_locking()
                        logging.info("global_locking result: {}".format(result))
                        if result == False:
                            logging.info("couldn't get all locks. Release all locks and end this thread.")
                            dejimautils.global_unlocking()
                            self.conn.send("HTTP/1.1 423 Locked".encode())
                            self.conn.close()
                            self.lock["lock"] = False
                            self.lock["holder"] = None
                            exit()

                        thread_type = "base"
                        logging.info("execute update for dejima view ...")
                        cur.execute(params_dict["sql_statements"])

                    elif url == "/update_dejima_view":
                        thread_type = "view"
                        logging.info("execute update for base table...")
                        view_name, sql_for_dejima_view = dejimautils.convert_to_sql_from_json(params_dict["view_update"])
                        view_name = view_name.replace("public.", "")
                        cur.execute(sql_for_dejima_view)

                    elif url == "/lock":
                        if self.lock["lock"] == False:
                            self.lock["lock"] = True
                            self.lock["holder"] = params_dict["holder"]
                            self.conn.send("HTTP/1.1 200 OK".encode())
                            self.conn.close()
                            logging.info("locked")
                            exit()
                        else:
                            logging.info("Request Blocked.")
                            self.conn.send("HTTP/1.1 423 Locked".encode())
                            self.conn.close()
                            exit()
                    
                    elif url == "/unlock":
                        logging.info("Lock holder: {}, Request peer: {}".format(self.lock["holder"], params_dict["holder"]))
                        if self.lock["holder"] == params_dict["holder"]:
                            self.lock["lock"] = False
                            self.lock["holder"] = None
                        self.conn.send("HTTP/1.1 200 OK".encode())
                        self.conn.close()
                        exit()


                    else:
                        self.conn.send("HTTP/1.1 404 Not Found".encode())
                        self.conn.close()
                        exit()

                    # phase2 : detect update for other dejima view and member of the view.
                    dejima_setting = {}
                    with open("/proxy/dejima_setting.json") as f:
                        dejima_setting = json.load(f)
                    dv_set_for_propagate = set(dejima_setting["dejima_view"][my_peer_name])
                    if thread_type == "view":
                        dv_set_for_propagate = dv_set_for_propagate - { view_name }

                    # phase 3 : propagate update for child peer
                    child_result = [] 
                    child_conns = []
                    if dv_set_for_propagate:
                        # phase3-2 : propagate dejima view update
                        thread_list = []
                        for dv_name in dv_set_for_propagate:
                            cur.execute("SELECT non_trigger_{}_detect_update();".format(dv_name))
                            update_json, *_ = cur.fetchone()
                            for peer_name in dejima_setting["peer_member"][dv_name]:
                                if peer_name != my_peer_name:
                                    t = threading.Thread(target=dejimautils.send_json_for_child, args=(update_json, peer_name, child_result, child_conns))
                                    t.start()
                                    thread_list.append(t)

                        logging.info("wait ack from child")
                        for thread in thread_list:
                            thread.join()

                    ack = True

                except psycopg2.Error as e:
                    logging.info("error: {}".format(e))
                    logging.info("Execption occurs. Abort start.")
                    ack = False

                # check ack/nak from children.
                commit_or_abort = "commit"
                for result in child_result:
                    if result != requests.codes.ok :
                        ack = False

                if thread_type == "view":
                    if ack:
                        self.conn.send("HTTP/1.1 200 OK".encode())
                    else:
                        self.conn.send("HTTP/1.1 500 Internal Server Error".encode())

                    logging.info("wait commit/abort")
                    commit_or_abort = self.conn.recv(1024).decode()

                # phase 7 : commit or abort
                if commit_or_abort == "commit":
                    db_conn.commit()
                    for s in child_conns:
                        s.sendall("commit".encode())
                        s.close()
                    logging.info("execution thread finished : commit")
                elif commit_or_abort == "abort":
                    db_conn.abort()
                    for s in child_conns:
                        s.sendall("abort".encode())
                        s.close()
                    logging.info("execution thread finished : abort")

                if thread_type == "base":
                    self.conn.send("HTTP/1.1 200 OK".encode())
                self.conn.close()

                self.lock["lock"] = False
                self.lock["holder"] = None
