import requests
import json
import threading
import time
import random

result = {}
result["commit"] = 0
result["abort"] = 0
result["locked"] = 0
stop = False
epsilon = 0

def p1_increment():
    payload_list = []
    payload1 = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='A'"}
    payload2 = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='B'"}
    payload_list.append(payload1)
    payload_list.append(payload2)

    while not stop:
        if epsilon > random.random():
            payload = payload_list[0]
        else:
            payload = payload_list[1]

        r = requests.post("http://localhost:8001/exec_transaction", json.dumps(payload))
        if r.status_code == 200:
            result["commit"] += 1
        elif r.status_code == 423:
            result["locked"] += 1
        else:
            result["abort"] += 1

def p4_increment():
    payload_list = []
    payload1 = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='A'"}
    payload2 = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='B'"}
    payload_list.append(payload1)
    payload_list.append(payload2)

    while not stop:
        if epsilon > random.random():
            payload = payload_list[0]
        else:
            payload = payload_list[1]

        r = requests.post("http://localhost:8004/exec_transaction", json.dumps(payload))
        if r.status_code == 200:
            result["commit"] += 1
        elif r.status_code == 423:
            result["locked"] += 1
        else:
            result["abort"] += 1


p1_inc_thread = threading.Thread(target=p1_increment)
p4_inc_thread = threading.Thread(target=p4_increment)

while True:
    try:
        epsilon = float(input("A increment rate : "))
        epsilon = epsilon/100
        if epsilon < 0 and epsilon > 1:
            continue
        break
    except:
        print("Not in 0...100. Again.")

input("Press Enter to start experiment. epsilon={}".format(epsilon))
print("---- start -----")
start_time = time.time()
p1_inc_thread.start()
p4_inc_thread.start()
time.sleep(30)
stop = True
thread_list = threading.enumerate()
thread_list.remove(threading.main_thread())
for thread in thread_list:
    thread.join()
print("---- finished -----")
print("commit : {}, abort : {}, locked : {}".format(result["commit"], result["abort"], result["locked"]))