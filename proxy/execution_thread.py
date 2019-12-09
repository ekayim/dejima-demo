import threading
import logging

class ExecutionThread(threading.Thread):
    def __init__(self, sql_statements="", source_xid=""):
        threading.Thread.__init__(self)
        self.sql_statements = sql_statements
        self.source_xid = source_xid
        self.commit_or_abort = ""
        self.termination_event = threading.Event()

    def run(self):
        logging.info("ExecutionThread : Start")
        logging.info("ExecutionThread : wait for commit")
        self.termination_event.wait()
        if self.commit_or_abort == "commit":
            print ("commit")
        elif self.commit_or_abort == "abort":
            print ("abort")
        logging.info("ExecutionThread : finished")


