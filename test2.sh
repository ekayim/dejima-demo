#!/bin/zsh
for i in `seq 0 99`
do
  http POST localhost:8004/exec_transaction sql_statements="INSERT INTO s VALUES ('A', $i);"
done
