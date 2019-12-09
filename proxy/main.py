from execution_thread import ExecutionThread
import socket
import logging
import json

logging.basicConfig(level=logging.DEBUG)
thread_dict = {}

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    connection_address = ('', 8000)
    s.bind(connection_address)
    s.listen(1)
    while True:
        conn, _ = s.accept()
        req = conn.recv(1024).decode()
        req_list = req.split("\r\n\r\n")
        url = req_list[0].split()[1]
        params_dict = json.loads(req_list[1])
            
        if url == "/update_dejima_view":
            # this action is called by other proxies only.
            logging.info("update_dejima_view is called.")
            
            # params parse
            sql_statements = params_dict["sql_statements"]
            source_xid = params_dict["source_xid"]

            t = ExecutionThread(sql_statements, source_xid)
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
        
        elif url == "/propagate":
            # this action is called by this proxy's postgreSQL only.
            logging.info("propagate is calle.")

        elif url == "/exec_transaction":
            # this action is called by user.
            logging.info("exec_transaction is called.")
            res_header = "HTTP/1.0 200 OK \r\n\r\nack"

        else :
            logging.info("Unexpected request : ", url)
            res_header = "HTTP/1.0 200 OK \r\n\r\nack"

        conn.send(res_header.encode())
        conn.close()
