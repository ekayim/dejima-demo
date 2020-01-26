#!/bin/zsh

tmux split-window -v "time ./test2.sh"
tmux split-window "time ./test.sh "
