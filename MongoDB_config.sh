#!/bin/bash

ID=$(id -u)
LOG_FILE="/tmp/mongodb.log"

# copy mongo.repo file to /etc/yum.repos.d/ 
cp /home/centos/Robo_Shop/repo_files/mongodb_repo/ /etc/yum.repos.d/mongo.repo

validate_user()
    if [ $ID -eq 0 ]; then
        echo "you are root user, good to install services"
    else
        echo "only root users can install servies sorry 😒"
    fi

validate_operation()
    if [ $1 -ne 0 ]; then
        echo "Sorry $2 failed"
    elif [ $1 -eq 0 ]; then
        echo " yeah $2 success"
    fi

# Installing mongodb
dnf install mongodb-org -y &>> $LOG_FILE

validate_operation $? "Installation of Mongo_DB"

# enable mongodb
systemctl enable mongod

validate_operation $? "Mongo_DB enableing is"

# Starting mongodb
systemctl start mongod

validate_operation $? "Mongo_DB started"

# modify the port number of mongod
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

validate_operation $? "port modification is"

# restarting mongodb
systemctl restart mongod
validate_operation $? "mongo_DB restart is success"

