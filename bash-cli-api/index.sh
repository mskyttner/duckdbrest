#!/bin/bash

#netcat -lp 8080 -e ./server.sh
socat TCP4-LISTEN:8181,reuseaddr,fork,end-close EXEC:./server.sh 2> /proc/1/fd/1 &
pid4="$!"
echo "$pid4" > '/tmp/bash-cli-api.pid'
chmod g+w '/tmp/bash-cli-api.pid'
wait "$pid4"

