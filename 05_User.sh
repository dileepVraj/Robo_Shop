#!/bin/bash

LOG_FILE="/tmp/user.log"

# User is a microservice that is responsible for user registrations and logins in Roboshop e-commercial portal.

validateUser() {
    if [ $(id -u) -eq 0 ] ; then
    echo " You are root user good to go"
    else
        echo "You are not a root user, wait switching to root user"
        sudo su -
        echo " Switched to root user"
    fi
}

validateOperation() {
    if [ $1 -eq 0 ]; then
    echo "Operation '$2' is successfull"
    else
        echo "Operation '$2' is falied"
        exit 1
    fi
}

addUser() {
    if id "$1" &>/dev/null;then
    echo "Yes user "$1" exists."
    else
        echo "No user "$1" is not available."
        useradd "$1"
        echo "New user "$1" is created."
    fi

}

createDirectory() {
    if [ -d $1 ]; then
    echo "Directory '$1' is available."
    else
        echo "Directory '$1' is not available"
        mkdir -p "$1"
        echo "Directory '$1' is created successfully."
    fi  
}

validateUser

#Developer has chosen NodeJs, Check with developer which version of NodeJS is needed. 
#Developer has set a context that it can work with NodeJS >18

#Install NodeJS, By default NodeJS 10 is available, We would like to enable 18 version and install list.

# you can list modules by 'using dnf module ist' command.

# disabling default nodejs module.
dnf module disable nodejs -y
validateOperation $? "default nodejs module"

# enabling nodejs:18 module.
dnf module enable nodejs:18 -y
validateOperation $? "nodejs 18 module enabled"

# Installing nodejs.
dnf install nodejs -y
validateOperation $? "nodejs installed"

# Adding the user.
addUser roboshop
validateOperation $? "user roboshop added"

# creating app directory.
createDirectory "/app"

# Download the application code to '/tmp' directory.

# Explanation:
# The '-L' option is used to tell the 'curl' to follow any redirects that might occour.
# The '-o' option specifies the output file. The '-o' option is followed by the path where you
# ..want to save the downloaded file.

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip
validateOperation $? "successfully downloaded application code"

# changing to '/app' directory.
cd /app
validateOperation $? "changed to '/app' directory"

# Unzipping downaloaded application code.
# The '-o' option tells 'unzip' to overwrite any existing files without prompting you for confirmation.
# If file extracted from '.zip' archive exists already in the target directory, they will be automatically
# ...replaced with the files from the archive.

unzip -o /tmp/user.zip
validateOperation $? "Unziped 'user.zip'"

# Installing npm (node package manager)
npm install &>> $LOG_FILE
validateOperation $? "Installed node package manager"

# We need to setup a new service in 'systemd' so systemctl can manage this service.
cp /home/Robo_Shop/service_files/User_service /etc/systemd/system/user.service
validateOperation $? "user_service copied successfully to /etc/systemd/system"

# Reloading daemon.
systemctl daemon-reload
validateOperation $? "daemon-reload is"

# enabling user.service
systemctl enable user
validateOperation $? "user enabled"

# starting user.service
systemctl start user
validateOperation $? "user start"

# Copying mongo.repo to /etc/yum.repos.d/ directory.
cp /home/Robo_Shop/repo_files/mongodb_repo /etc/yum.repos.d/mongo.repo
validateOperation $? "mongo.repo file created"

# Installing mongodb-shell
dnf install mongodb-org-shell -y
validateOperation $? "Mongodb-shell installation"

# Loading schema to mongodb
mongo --host 172.31.45.7</app/schema/user.js
validateOperation $? "loading schema to Mongo_db is "









