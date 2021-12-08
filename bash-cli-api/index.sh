#!/bin/bash
socat TCP4-LISTEN:8181,reuseaddr,fork EXEC:./server.sh
#netcat -lp 8080 -e ./server.sh
