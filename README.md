# Dejima Demo
- db : ekayim/dejima-postgres <postgres:11.2-alpine customed>
- proxy : ekayim/dejima-proxy <python3.7.2 customed>

# action binding URL
**user can use only /exec_transaction. Other action is supposed the one which is called by peer proxy.**


## /exec_transaction
### arg (POST)
- sql_statements
- my_peer_name
### function
This action generates execution thread for base table.
In this thread, the following occurs:
- update base table
- detect update for other dejima view, and send the diff for child peer.
- gathering all ack or nak, and decide commit or abort according to it.
- commit or abort , and send the instruction to child peer.

## /update_dejima_view
### arg (POST)
- view_update
- source_xid
- parent_peer
### function
This action generates execution thread for dejima view.
In this thread, the following occurs:
- update dejima view
- detect update for other dejima view, and send the diff for child peer.
- gathering all ack or nak, and send ack or nak to parent peer according to it.
- accept commit/abort from parent peer, and exec the instruction.

## /accept_ack
### arg (POST)
- event_key
- source_xid
- ack_or_nak
### function
This action accept ack or nak from child peer.
Accepting this, then send the content to execution thread.
Notification about accepting ack is implemented by dictionary whoose value is event object.
This dictionary's key is event_key.

## /commit_or_abort
### arg (POST)
- source_xid
- commit_or_abort
### function
This function accept commit or abort from parent peer.
Accepting this, then exec Event.set().
This event is notify that commit or abort instruction arrives.
