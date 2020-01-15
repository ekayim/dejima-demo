from execution_thread import ExecutionThread
import socket
import logging

logging.basicConfig(level=logging.DEBUG)
lock = {"lock": False, "holder": None}

# pdb.set_trace()

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    connection_address = ('', 8000)
    s.bind(connection_address)
    s.listen(5)
    while True:
        conn, _ = s.accept()
        t = ExecutionThread(conn, lock)
        t.start()
