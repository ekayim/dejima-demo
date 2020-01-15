#!/bin/zsh
for i in `seq 0 99`
do
  ./request.sh bank $i
done
