import json
import socket
import os

def convert_to_sql_from_json(json_data):
    # arg : json_data from other peer
    # output : view name(str) , sql statements for view(str)
    sql_statements = ""
    json_dict = json.loads(json_data)
    for insert in json_dict["insertions"]:
        columns = "("
        values = "("
        for column, value in insert.items():
            columns += "{}, ".format(column)
            if not value:
                values += "NULL, "
            else:
                values += "'{}', ".format(value)
        columns = columns[0:-2] + ")"
        values = values[0:-2] + ")"
        sql_statements += "INSERT INTO {} {} VALUES {};\n".format(json_dict["view"], columns, values)

    for delete in json_dict["deletions"]:
        where = ""
        for column, value in delete.items():
            if not value:
                continue
            where += "{}='{}' AND ".format(column, value)
        where = where[0:-4]
        sql_statements += "DELETE FROM {} WHERE {};\n".format(json_dict["view"], where)

    return json_dict["view"], sql_statements

def send_json_for_child(json_data, peer_name, child_result, child_conns):

    target, *_ = socket.getaddrinfo(peer_name+"-proxy", 8000)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(target[4])
    request_header = "POST /update_dejima_view HTTP/1.1"
    payload = {"view_update": json_data }
    message_body = json.dumps(payload)
    message = request_header + "\r\n\r\n" + message_body
    s.sendall(message.encode())
    res = s.recv(1024).decode()
    status_code = res.split()[1]

    child_result.append(status_code)
    child_conns.append(s)

def global_locking():
    my_peer_name = os.environ['PEER_NAME']

    dejima_setting = {}
    with open("/proxy/dejima_setting.json") as f:
        dejima_setting = json.load(f)

    for peer_name in dejima_setting["dejima_participants"]:
        if peer_name != my_peer_name:
            target, *_ = socket.getaddrinfo(peer_name+"-proxy", 8000)
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect(target[4])
            payload = {"holder": my_peer_name}
            request = "POST /lock HTTP/1.1\r\n\r\n" + json.dumps(payload)
            s.sendall(request.encode())
            res = s.recv(1024).decode()
            status_code = res.split()[1]
            s.close()

            if status_code == "423":
                return False

    return True

def global_unlocking():
    my_peer_name = os.environ['PEER_NAME']

    dejima_setting = {}
    with open("/proxy/dejima_setting.json") as f:
        dejima_setting = json.load(f)

    for peer_name in dejima_setting["dejima_participants"]:
        if peer_name != my_peer_name:
            target, *_ = socket.getaddrinfo(peer_name+"-proxy", 8000)
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect(target[4])
            payload = {"holder": my_peer_name}
            request = "POST /unlock HTTP/1.1\r\n\r\n" + json.dumps(payload)
            s.sendall(request.encode())
            s.close()
