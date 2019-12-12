from execution_thread import ExecutionThreadForView, ExecutionThreadForBase
import socket
import logging
import json
import uuid
import os

logging.basicConfig(level=logging.DEBUG)
thread_dict = {}

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    connection_address = ('', 8000)
    s.bind(connection_address)
    s.listen(1)
    while True:
        conn, _ = s.accept()
        req = conn.recv(1024).decode()
        request_line, message_body = req.split("\r\n\r\n")
        url = request_line.split()[1]
        logging.info("req : {}".format(req))
        params_dict = json.loads(message_body)
            
        if url == "/update_dejima_view":
            # this action is called by other proxies only.
            logging.info("update_dejima_view is called.")
            
            # params parse
            view_update = params_dict["view_update"]
            source_xid = params_dict["source_xid"]
            parent_peer = params_dict["parent_peer"]

            t = ExecutionThreadForView(view_update, source_xid, parent_peer)
            thread_dict[source_xid] = t
            t.start()
            res_header = "HTTP/1.0 200 OK \r\n\r\nack"

        elif url == "/commit_or_abort":
            # this action is called by parent proxies only.
            logging.info("commit_or_abort is called.")

            # params parse
            source_xid = params_dict["source_xid"]
            commit_or_abort = params_dict["commit_or_abort"]

            t = thread_dict[source_xid]
            t.commit_or_abort = commit_or_abort
            t.termination_event.set()
            
            t.join()
            res_header = "HTTP/1.0 200 OK \r\n\r\nack"
        
        elif url == "/accept_ack":
            # this action is called by child proxies only.
            logging.info("accept_ack is called.")

            # params parse
            event_key = params_dict["event_key"]
            source_xid = params_dict["source_xid"]
            ack_or_nak = params_dict["ack_or_nak"]

            # inform execution thread about ack
            thread_dict[source_xid].ack_dict[event_key] = ack_or_nak
            thread_dict[source_xid].ack_event_dict[event_key].set()
            res_header = "HTTP/1.0 200 OK \r\n\r\nack"

        elif url == "/exec_transaction":
            # this action is called by user.
            logging.info("exec_transaction is called.")

            # params parse
            sql_statements = params_dict["sql_statements"]

            my_peer_name = os.environ['PEER_NAME']
            source_xid = str(uuid.uuid4())

            t = ExecutionThreadForBase(sql_statements, source_xid)
            thread_dict[source_xid] = t
            t.start()
            res_header = "HTTP/1.0 200 OK \r\n\r\nack"

        else :
            logging.info("Unexpected request : ", url)
            res_header = "HTTP/1.0 200 OK \r\n\r\nack"

        conn.send(res_header.encode())
        conn.close()
