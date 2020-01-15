#!/bin/bash
#
# @(#) request.sh
#
# Usage:
#   request.sh num
#     peer name - アクセスするピアの名前を指定
#     num  - insert するデータの id を指定
#
# Description:
#   request for dejima proxy.
#
if [ $# -eq 2 ]; then
  if [ $1 = "bank" ]; then
    http POST localhost:8001/exec_transaction sql_statements="INSERT INTO bank_users VALUES ($2, 'f$2', 'l$2', 'i$2', 'a$2', 'p$2');"
  elif [ $1 = "government" ]; then
    http POST localhost:8002/exec_transaction sql_statements="INSERT INTO government_users VALUES ($2, 'f$2', 'l$2', 'p$2', 'a$2', 'b$2');"
  elif [ $1 = "insurance" ]; then 
    http POST localhost:8003/exec_transaction sql_statements="INSERT INTO insurance_users VALUES ($2, 'f$2', 'l$2', 'i$2', 'a$2', 'b$2');"
  fi
else
  echo -e "usage: ./request.sh peer_name num"
  exit 1
fi
