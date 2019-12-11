import threading
import logging
import psycopg2
import dejimautils
import os
import json
import requests

class ExecutionThreadForView(threading.Thread):
    def __init__(self, view_update="", source_xid="", parent_peer=""):
        threading.Thread.__init__(self)
        self.view_update = view_update
        self.source_xid = source_xid
        self.parent_peer = parent_peer
        self.ack_event_dict = {}
        self.ack_dict = {}
        self.commit_or_abort = ""
        self.termination_event = threading.Event()

    def run(self):
        logging.info("ExecutionThreadForView : Start")
        my_peer_name = os.environ['PEER_NAME']
        with psycopg2.connect("dbname=postgres user=dejima password=barfoo host={}-postgres port=5432".format(my_peer_name)) as conn:
            with conn.cursor() as cur:
                # note : in psycopg2, transaction is valid as default, so no need to exec "BEGIN;"

                # phase1 : execute update for certain dejima view
                view_name, sql_for_dejima_view = dejimautils.convert_to_sql_from_json(self.view_update)
                view_name = view_name.replace("public.", "")
                cur.execute(sql_for_dejima_view)

                # phase2 : detect update for other dejima view and member of the view.
                dejima_setting = {}
                with open("/proxy/dejima_setting.json") as f:
                    dejima_setting = json.load(f)
                dv_set_for_propagate = set(dejima_setting["dejima_view"][my_peer_name])
                dv_set_for_propagate = dv_set_for_propagate - { view_name }

                update_view_dict = {}
                for dejima_view in dv_set_for_propagate:
                    update_view_dict[dejima_view]["sql_statements"] = "SELECT non_trigger_{}_detect_update()".format(dejima_view)
                    update_view_dict[dejima_view]["peer_member"] = dejima_setting["peer_member"][dejima_view]

                # phase 3 : propagate update for child peer
                peer_set = set()
                if dv_set_for_propagate:
                    # phase3-2 : propagate dejima view update
                    for dv_name in dv_set_for_propagate:
                        cur.execute("SELECT non_trigger_{}_detect_update();".format(dv_name))
                        update_json, *_ = cur.fetchone()
                        for peer_name in dejima_setting["peer_member"][dv_name]:
                            requests.post( 'http://{}-proxy:8000/update_dejima_view'.format(peer_name), params={'source_xid': self.source_xid, 'view_update': update_json, 'parent_peer': my_peer_name})
                        self.ack_event_dict["{}:{}".format(dv_name, peer_name)] = threading.Event()
                        self.ack_dict["{}:{}".format(dv_name, peer_name)] = "nak"
                        peer_set.add(peer_name)
                    for event in ack_event_dict.values:
                        event.wait()

                # phase 4 : check commitability ( surveying )
                # PREPARE TRANSACTION is not available, so need to check this transaction commitable by yourself.

                # phase 5 : send ack or nak for parent peer
                ack = True
                for result in ack_dict.values:
                    if result != "nak":
                       ack = False 
                if ack:
                    requests.post('http://{}-proxy:8000/accept_ack'.format(self.parent_peer), params={'event_key':"{}:{}".format(view_name, my_peer_name), 'source_xid':self.source_xid, 'ack_or_nak': "ack"})
                else:
                    requests.post('http://{}-proxy:8000/accept_ack'.format(self.parent_peer), params={'event_key':"{}:{}".format(view_name, my_peer_name), 'source_xid':self.source_xid, 'ack_or_nak': "nak"})

                # phase 6 : wait for commit
                logging.info("ExecutionThreadForView : wait for commit")
                self.termination_event.wait()

                # phase 7 : commit or abort
                if self.commit_or_abort == "commit":
                    conn.commit()
                    for peer in peer_set:
                        requests.post('http://{}-proxy:8000/commit_or_abort'.format(peer), params={'source_xid':self.source_xid, 'commit_or_abort': "commit"})
                    logging.info("xid [{}] execution thread finished. result->commit".format(self.source_xid))
                elif self.commit_or_abort == "abort":
                    conn.abort()
                    for peer in peer_set:
                        requests.post('http://{}-proxy:8000/commit_or_abort'.format(peer), params={'source_xid':self.source_xid, 'commit_or_abort': "abort"})
                    logging.info("xid [{}] execution thread finished. result->abort".format(self.source_xid))

class ExecutionThreadForBase(threading.Thread):
    def __init__(self, sql_statements="", source_xid=""):
        threading.Thread.__init__(self)
        self.sql_statements = sql_statements
        self.source_xid = source_xid
        self.ack_event_dict = {}
        self.ack_dict = {}

    def run(self):
        logging.info("ExecutionThreadForView : Start")
        my_peer_name = os.environ['PEER_NAME']
        with psycopg2.connect("dbname=postgres user=dejima password=barfoo host={}-postgres port=5432".format(my_peer_name)) as conn:
            with conn.cursor() as cur:
                # note : in psycopg2, transaction is valid as default, so no need to exec "BEGIN;"

                # phase1 : execute update for base table
                cur.execute(self.sql_statements)

                # phase2 : detect update for other dejima view and member of the view.
                dejima_setting = {}
                with open("/proxy/dejima_setting.json") as f:
                    dejima_setting = json.load(f)
                dv_set_for_propagate = set(dejima_setting["dejima_view"][my_peer_name])
                dv_set_for_propagate = dv_set_for_propagate - { view_name }

                update_view_dict = {}
                for dejima_view in dv_set_for_propagate:
                    update_view_dict[dejima_view]["sql_statements"] = "SELECT non_trigger_{}_detect_update()".format(dejima_view)
                    update_view_dict[dejima_view]["peer_member"] = dejima_setting["peer_member"][dejima_view]

                # phase 3 : propagate update for child peer
                peer_set = set()
                if dv_set_for_propagate:
                    # phase3-2 : propagate dejima view update
                    for dv_name in dv_set_for_propagate:
                        cur.execute("SELECT non_trigger_{}_detect_update();".format(dv_name))
                        update_json, *_ = cur.fetchone()
                        for peer_name in dejima_setting["peer_member"][dv_name]:
                            requests.post( 'http://{}-proxy:8000/update_dejima_view'.format(peer_name), params={'source_xid': self.source_xid, 'view_update': update_json, 'parent_peer': my_peer_name})
                        self.ack_event_dict["{}:{}".format(dv_name, peer_name)] = threading.Event()
                        self.ack_dict["{}:{}".format(dv_name, peer_name)] = "nak"
                        peer_set.add(peer_name)
                    for event in ack_event_dict.values:
                        event.wait()

                # phase 4 : check commitability ( surveying )
                # PREPARE TRANSACTION is not available, so need to check this transaction commitable by yourself.

                ack = True
                for result in ack_dict.values:
                    if result != "nak":
                       ack = False 
                if ack:
                    conn.commit()
                    logging.info("xid [{}] base execution thread finished. result->commit".format(self.source_xid))
                else:
                    conn.abort()
                    logging.info("xid [{}] base execution thread finished. result->abort".format(self.source_xid))

