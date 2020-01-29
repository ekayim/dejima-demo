import requests
import json
import threading
import time

result = {}
result["commit"] = 0
result["abort"] = 0
stop = False

def a_increment():
    while not stop:
        payload = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='A'"}
        r = requests.post("http://localhost:8001/exec_transaction", json.dumps(payload))
        if r.status_code == 200:
            result["commit"] += 1
        else:
            result["abort"] += 1

def b_increment():
    while not stop:
        payload = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='B'"}
        r = requests.post("http://localhost:8004/exec_transaction", json.dumps(payload))
        if r.status_code == 200:
            result["commit"] += 1
        else:
            result["abort"] += 1


a_inc_thread = threading.Thread(target=a_increment)
b_inc_thread = threading.Thread(target=b_increment)

input("Press Enter to start experiment")
print("---- start -----")
start_time = time.time()
a_inc_thread.start()
b_inc_thread.start()
time.sleep(60)
stop = True
thread_list = threading.enumerate()
thread_list.remove(threading.main_thread())
for thread in thread_list:
    thread.join()
print("---- finished -----")
print("commit : {}, abort : {}".format(result["commit"], result["abort"]))