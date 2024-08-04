#!/bin/bash

# storing user ID in a variable.
ID=$(id -u)
LOG_FILE="/tmp/catalogue.log"

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
        echo " yeah 👍 $2"
    fi

add_user() 
    if [ $1 -ne 0 ]; then
        echo "No user called '$2' exists."
        useradd $2
        echo "User '$2' added successfully."
    else
        echo "User '$2' is already exists."
    fi




createDirectory() 
    # This function takes 2 arguments, 1.path to directory we want to check if it exists.
    # 2. if not the path we want to create a directory in, with directory name.
    if [ test -d $1 -eq 0 ]; then
        echo "directory $1 is available"
    else
        echo "directory $1 is not available"
        mkdir $2
        echo "directory $2 is created"
        cd $2
        echo "changed to directory $2"  



#Disabling default nodejs module.
dnf module disable nodejs -y
validate_operation $? "NodeJS default 'module 10' is disabled"

#Enabling NodeJS version 18.
dnf module enable nodejs:18 -y
validate_operation $? "NodeJS 18 module is enabled."

#Installing NodeJS version 18.
dnf install nodejs -y &>> $LOG_FILE

#Capturing exit code in a variable after executing 'id <username> command which returns the exit code.'
id roboshop
IsUserExists=$($?)
add_user $IsUserExists roboshop

# Changing directory to root.
cd /

# Verifying do '/app' directory is available or not and if not create one.
createDirectory "/app" "/app"

# Downloading 'catalogue' application code to /tmp directory.
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

# unziping the downloaded catalogue.zip file in /app directory.
unzip -o /tmp/catalogue.zip

# installing npm package manager for nodejs packages.
npm install &>> $LOG_FILE
validate_operation $? "npm installed"

# adding catalogue.service file in /etc/systemd/system/ directory.
cp /home/centos/Robo_Shop/service_files/Catalogue_service /etc/systemd/system/catalogue.service
validate_operation $? "catalogue.service is created"

# Restarting the system daemon.
systemctl daemon-reload
validate_operation $? "daemon reloaded good to go.."

# Start catalogue service.
systemctl enable catalogue
validate_operation $? "Catalogue enabled"
systemctl start catalogue
validate_operation $? "Catalogue started"

# creating mongo.repo file in /etc/yum.repos.d/ directory.
cp /home/centos/Robo_Shop/repo_files/mongodb_repo /etc/yum.repos.d/mongo.repo
validate_operation $? "mongo.repo file created"

# Installing mongodb shell(client)
dnf install mongodb-org-shell -y &>> $LOG_FILE
validate_operation $? "Mongo_DB client installed successfully"

# Loading schema to mongodb from catalogue 'ms' 
mongo --host 172.31.34.177 </app/schema/catalogue.js
validate_operation $? "Successfully loaded catalogue schema to mongo_db"
