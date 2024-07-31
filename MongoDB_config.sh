#!/bin/bash

ID=$(id -u)
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NORMAL="\e[0m"

DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE=/tmp/mongodb.log

echo "Hello"

echo "$GREEN Script started executed" &>> $LOG_FILE 


