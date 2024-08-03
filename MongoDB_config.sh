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
            echo -e "$RED $2 .....failed $NORMAL"
        else
            echo -e "$GREEN $2 ....Success $NORMAL"
            echo -e "$GREEN $2 $NORMAL"
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

cp /home/centos/Robo_Shop/repo_files/mongodb_repo /etc/yum.repos.d/mongo.repo &&> $LOG_FILE

if [ $? -eq 0 ]; then
    echo -e "$GREEN Successfully copied 'mongodb_repo' file to 'yum.repos.d' directory $NORMAL" &>> $LOG_FILE
else
    echo -e "$RED 'mongodb_repo' file to 'yum.repos.d' directory is failed $NORMAL" &>> $LOG_FILE


# validating copy of 'mongodb_repo' file from project directory to 'yum.repos.d' directory.
validate_operation $? "Copied mongo_repo file to 'yum.repos.d' directory as mongo.repo"



# Installing Mongo_db...
dnf install mongodb-org -y

if [ $? -eq 0 ]; then
    echo -e "$GREEN Successfully Installed mongo_db $NORMAL" &>> $LOG_FILE
else
    echo -e "$RED 'mongodb_db' installation failed $NORMAL" &>> $LOG_FILE


# validating 'mongodb' service installation.
validate_operation $? "Mongo_DB installation"

# enabling mongo_db service.
systemctl enable mongod
validate_operation $? "Mongo_DB enabled successfully"

# Starting mongo_db service
systemctl start mongod
validate_operation $? "successfully started mongodb"

# Now we have to change mongodb default port to public port without manual intervention by using SED
#.. editor(Stream Editor) where it can edit a text file by reading it in streams.

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongo.conf

validate_operation $? "Successfully modified default port to public port using 'sed' editor."

systemctl restart mongod &>> $LOG_FILE

validate_operation $? "Mongo_db restarted successfully."