import requests
import json
import threading
import time
import random

result = {}
p1_result = {}
p4_result = {}
epsilon = 0
p4_target = ""

def p1_increment():
    payload_list = []
    payload1 = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='A'"}
    payload2 = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='B'"}
    payload_list.append(payload1)
    payload_list.append(payload2)
    for key1 in ["A", "B"]:
        p1_result[key1] = {}
        for key2 in ["try", "commit", "abort", "locked"]:
            p1_result[key1][key2] = 0

    while not stop:
        if epsilon > random.random():
            payload = payload_list[0]
            ref_result = p1_result["A"]
        else:
            payload = payload_list[1]
            ref_result = p1_result["B"]

        try:
            r = requests.post("http://localhost:8001/exec_transaction", json.dumps(payload))
        except:
            continue

        ref_result["try"] += 1
        if r.status_code == 200:
            ref_result["commit"] += 1
        elif r.status_code == 423:
            ref_result["locked"] += 1
        elif r.status_code == 500:
            ref_result["try"] -= 1
        else:
            ref_result["abort"] += 1

def p4_increment():
    payload = ""
    payload1 = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='A'"}
    payload2 = {"sql_statements": "UPDATE s SET value=value+1 WHERE id='B'"}
    for key1 in ["A", "B"]:
        p4_result[key1] = {}
        for key2 in ["try", "commit", "abort", "locked"]:
            p4_result[key1][key2] = 0

    if p4_target == "a":
        payload = payload1
        ref_result = p4_result["A"]
    else:
        payload = payload2
        ref_result = p4_result["B"]

    while not stop:

        try:
            r = requests.post("http://localhost:8004/exec_transaction", json.dumps(payload))
        except:
            continue

        ref_result["try"] += 1
        if r.status_code == 200:
            ref_result["commit"] += 1
        elif r.status_code == 423:
            ref_result["locked"] += 1
        elif r.status_code == 500:
            ref_result["try"] -= 1
        else:
            ref_result["abort"] += 1

p4_target = input("p4 target (a/b) : ")
if p4_target != "a" and p4_target != "b":
    print("not a or b")
    exit()

input("Press Enter to start experiment ")

for i in [0, 0.2, 0.4, 0.6, 0.8, 1.0]:
    stop = False

    p1_inc_thread = threading.Thread(target=p1_increment)
    p4_inc_thread = threading.Thread(target=p4_increment)

    epsilon = i
    print("---- epsilon : {} -----".format(epsilon))
    start_time = time.time()
    p1_inc_thread.start()
    time.sleep(0.25)
    p4_inc_thread.start()
    time.sleep(60)
    stop = True
    thread_list = threading.enumerate()
    thread_list.remove(threading.main_thread())
    for thread in thread_list:
        thread.join()
    print("----- result -----")
    print("p1_A")
    print("try:{}, commit:{}, abort:{}, locked:{}".format(p1_result["A"]["try"], p1_result["A"]["commit"], p1_result["A"]["abort"], p1_result["A"]["locked"]))
    print("p1_B")
    print("try:{}, commit:{}, abort:{}, locked:{}".format(p1_result["B"]["try"], p1_result["B"]["commit"], p1_result["B"]["abort"], p1_result["B"]["locked"]))
    print("p4_A")
    print("try:{}, commit:{}, abort:{}, locked:{}".format(p4_result["A"]["try"], p4_result["A"]["commit"], p4_result["A"]["abort"], p4_result["A"]["locked"]))
    print("p4_B")
    print("try:{}, commit:{}, abort:{}, locked:{}".format(p4_result["B"]["try"], p4_result["B"]["commit"], p4_result["B"]["abort"], p4_result["B"]["locked"]))
    time.sleep(10)
