from execution_thread import ExecutionThread
import socket
import logging
import json
import uuid
import os
import pdb

logging.basicConfig(level=logging.DEBUG)
thread_dict = {}

# pdb.set_trace()

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    connection_address = ('', 8000)
    s.bind(connection_address)
    s.listen(5)
    while True:
        conn, _ = s.accept()
        t = ExecutionThread(conn, thread_dict)
        t.start()
