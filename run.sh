#!/bin/bash
 if [ "$#" -ne  "1" ]
   then
     echo "usage: $ ./run.sh [ download | auto | auto-cpu | invoke | sygil | sygil-sl ]"
 else
     USER_ID=$(id -u):$(id -g) docker compose --profile $1 up --build
 fi
