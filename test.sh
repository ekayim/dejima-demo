#!/bin/zsh
for i in `seq 1 100`
do
  http POST localhost:8001/exec_transaction sql_statements="UPDATE s SET value=value+1 WHERE id='A'"
done
