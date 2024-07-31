#!/bin/bash

ID=$(id -u)
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NORMAL="\e[0m"

ID=$(id -u)
DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE=/tmp/mongodb.log



echo -e "$GREEN Script started executed" &>> $LOG_FILE 

validate_operation() {
    if [ $1 -ne 0 ]
        then
            echo -e "$2 $RED .....failed $NORMAL"
        else
            echo -e "$2 $GREEN ....Success $NORMAL"
    fi
}

validate_user() {
    if [ $ID -ne 0 ]; then
        echo " $RED can't install services with user normal user please try with user with root permissions $NORMAL"
        exit 1
    else
        echo " you are root user "
    fi

}

# Copying contents of mongo_repo file to /etc/yum.repos.d/ directory.

cp /d/My_Projects/RoboShop/repo_files/mongodb_repo /etc/yum.repos.d/mongo.repo &&> $LOG_FILE

validate_operation $? "Copied mongo_repo file to 'yum.repos.d' directory as mongo.repo











