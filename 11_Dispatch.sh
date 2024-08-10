#!/bin/bash

# Readme:

# Dispatch is the service which dispatches the product after purchase.
# It is written in GoLang, So wanted to install GoLang.
#-------------------------------------------------------------------------
# This application is developed with Go programming language.

validateOperation() {
    if [ $1 -eq 0 ];then
    echo "$2 is success."
    else
        echo "$2 is failed." 
    fi
}

userAdd() {
    if id "$1" &>/dev/null; then
    echo "User '$1' exists."
    else
        echo "User '$1' didn't exist."
        useradd "$1"
        echo "User '$1' is created."
    fi
}

createDirectory() {
    if [ -d $1 -eq 0 ]; then
    echo "Directory '$1' is available."
    else
        echo "Directory '$1' is not availalbe."
        mkdir -p "$1"
        echo "Directory '$1' created successfully."
    fi
}

# Installing Go lang.
dnf install golang -y
validateOperation $? "Go installation"

# Creating user.
userAdd "roboshop"


# creating application directory.
createDirectory "/app"

# Downloading the application code to the /tmp directory.
curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip
validateOperation $? "Application downloading"

# Changing to application directory. 
cd /app 
validateOperation $? "Cd to application directory"

# Unziping application archive file in /app directory.
unzip -o /tmp/dispatch.zip
validateOperation $? "Unzipping application archive"

#--------------------------------------------------------------------------------------------------------------
# Every application is developed by development team will have some common softwares that they use as libraries.
# This application also have the same way of defined dependencies in the application configuration.
#--------------------------------------------------------------------------------------------------------------

# Downloading the dependencies and building the software.
go mod init dispatch
go get
go build
validateOperation $? "Application build"

# Copying dispatch.service to /etc/systemd/system directroy.
cp /home/Robo_Shop/service_files/Dispatch_service /etc/systemd/system/dispatch.service
validateOperation $? "Dispatch.service moved to /etc/systemd/system"

# Reload the Daemon.
systemctl daemon-reload
validateOperation $? "Daemon reload"

# Enable & Strat dispatch the service
systemctl enable dispatch.service
validateOperation $? "dispatch.service enabling"
systemctl start dispatch.service
validateOperation $? "dispatch.service start"




