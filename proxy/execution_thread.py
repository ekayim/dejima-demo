import threading
import logging
import psycopg2
import dejimautils
import os
import json

class ExecutionThread(threading.Thread):
    def __init__(self, sql_statements="", source_xid=""):
        threading.Thread.__init__(self)
        self.sql_statements = sql_statements
        self.source_xid = source_xid
        self.ack_or_nak = ""
        self.ack_event = threading.Event()
        self.commit_or_abort = ""
        self.termination_event = threading.Event()

    def run(self):
        logging.info("ExecutionThread : Start")
        with psycopg2.connect("dbname=postgres user=dejima password=barfoo host=bank-postgres port=5432") as conn:
            with conn.cursor() as cur:
                # note : in psycopg2, transaction is valid as default, so no need to exec "BEGIN;"

                # phase1 : execute update for certain dejima view
                cur.execute("INSERT INTO bank_users VALUES (1, 'first', 'last', 'iban', 'address', 'phone');")

                # phase2 : detect other dejima view update
                # if no other dejima view exists, send ack for parent proxy
                dejima_setting = {}
                with open("/proxy/dejima_setting.json") as f:
                    dejima_setting = json.load(f)
                    logging.info("load success")
                dejima_view_list = dejima_setting["dejima_view"][os.environ['PEER_NAME']]
                    
                cur.execute("SELECT non_trigger_dejima_bank_detect_update();")
                return_value, *_ = cur.fetchone()
                logging.info(type(return_value))
                logging.info(return_value)
                # return_value -> str

                # phase3 : 

                logging.info("ExecutionThread : wait for commit")
                self.termination_event.wait()

                if self.commit_or_abort == "commit":
                    conn.commit()
                    logging.info("xid [{}] execution thread finished. result->commit".format(self.source_xid))
                elif self.commit_or_abort == "abort":
                    conn.abort()
                    logging.info("xid [{}] execution thread finished. result->abort".format(self.source_xid))
