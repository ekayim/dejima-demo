import threading

class ExecutionThread(threading.Thread):
    def __init__(self, sql_statements="", source_xid=""):
        threading.Thread.__init__(self)
        self.sql_statements = sql_statements
        self.source_xid = source_xid
        self.termination_operation = ""
        self.termination_event = threading.Event()

    def run(self):
        print("execute sql and non_trigger function")
        self.termination_event.wait()
        if self.termination_operation == "commit":
            print ("commit")
        elif self.termination_operation == "abort":
            print ("abort")


