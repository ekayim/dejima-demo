import os
import socket
import logging
logging.basicConfig(level=logging.DEBUG)

CC_METHOD = os.environ['CC_METHOD']

if CC_METHOD == "global_lock":
    from global_lock_thread import ExecutionThread
    lock = {"lock": False, "holder": None}
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        connection_address = ('', 8000)
        s.bind(connection_address)
        s.listen(5)
        while True:
            conn, _ = s.accept()
            t = ExecutionThread(conn, lock)
            t.start()

elif CC_METHOD == "ticket":
    from ticket_thread import ExecutionThread
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        connection_address = ('', 8000)
        s.bind(connection_address)
        s.listen(5)
        while True:
            conn, _ = s.accept()
            t = ExecutionThread(conn)
            t.start()
