#!/bin/bash

ID=$(id -u)
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NORMAL="\e[0m"

DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE=/tmp/mongodb.log

echo -e "$GREEN Script started executing" &>> $LOG_FILE 

validate_operation() {
    if [ $1 -ne 0 ]; then
        echo -e "$RED $2 .....failed $NORMAL"
        echo -e "$DATE_TIME: $2 .....failed" &>> $LOG_FILE
        exit 1
    else
        echo -e "$GREEN $2 ....Success $NORMAL"
        echo -e "$DATE_TIME: $2 ....Success" &>> $LOG_FILE
    fi
}

validate_user() {
    if [ $ID -ne 0 ]; then
        echo -e "$RED Can't install services with a normal user, please try with a user with root permissions $NORMAL"
        exit 1
    else
        echo "You are root user"
    fi
}

# Validate user
validate_user

# Copying contents of mongo_repo file to /etc/yum.repos.d/ directory.
cp /home/centos/Robo_Shop/repo_files/mongodb_repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
validate_operation $? "Copied mongo_repo file to 'yum.repos.d' directory as mongo.repo"

# Installing MongoDB
dnf install mongodb-org -y &>> $LOG_FILE
validate_operation $? "Mongo_DB installation"

# Enabling MongoDB service
systemctl enable mongod &>> $LOG_FILE
validate_operation $? "Mongo_DB enabled successfully"

# Starting MongoDB service
systemctl start mongod &>> $LOG_FILE
validate_operation $? "Successfully started MongoDB"

# Modifying MongoDB default port to public port using 'sed'
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
validate_operation $? "Successfully modified default port
