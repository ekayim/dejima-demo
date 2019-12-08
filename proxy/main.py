import threading
from execution_thread import ExecutionThread
import socket

thread_dict = {}

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    connection_address = ('localhost', 8000)
    s.bind(connection_address)
    s.listen(1)
    while True:
        conn, _ = s.accept()
        req = conn.recv(1024).decode()
        fields = req.split("\r\n")
        url = fields[0].split()[1]
            
        if url == "/update_dejima_view":
            params = fields[-1].
            t = ExecutionThread(sql_statements, source_xid)
            thread_dict[source_xid] = t
            t.start()
            res_header = "HTTP/1.0 200 OK \r\n\r\nack"

        elif url == "/commit_or_abort":
            t = thread_dict[source_xid]
            t.termination_operation = #result
            t.termination_event.set()
            t.join()
            res_header = "HTTP/1.0 200 OK \r\n\r\nack"
        conn.send(res_header.encode())
        conn.close()
