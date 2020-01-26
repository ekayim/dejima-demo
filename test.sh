#!/bin/zsh
for i in `seq 0 99`
do
  http POST localhost:8001/exec_transaction sql_statements="INSERT INTO s VALUES ('B', $i);"
done
