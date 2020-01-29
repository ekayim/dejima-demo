#!/bin/zsh
for i in `seq 0 99`
do
  http POST localhost:8004/exec_transaction sql_statements="UPDATE s SET value=value+1 WHERE ID='B'"
done
