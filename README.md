# Dejima Demo
- db : ekayim/dejima-postgres <postgres:11.2-alpine customed>
- proxy : ekayim/dejima-proxy <python3.7.2 customed>

# Usage
- run all containers using `docker-compose up`.
- Post sql statements for a peer's base table following http protocol. You should call "/exec_transaction". 
	- port : see the docker-compose file.
	- method : POST
	- params : sql_statements (string)
	- url : /exec_transaction
For example, using HTTPie:
```
http post localhost:8001/exec_transaction sql_statements="INSERT INTO bank_users VALUES (1, 'John', 'Smith', 'IBAN', 'address', 'phone_number');"
```
- The update will propagate, and then commit or abort following 2-phase commit protocol.
