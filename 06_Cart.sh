#!/bin/bash

LOG_FILE="/tmp/user.log"

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
    echo "'$2' is successfull"
    else
        echo "'$2' is falied"
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

# Validating user.
validateUser

# Disabling nodejs default version.
dnf module disable nodejs -y &>> $LOG_FILE
validateOperation $? "Default Nodejs module disable"

# Enabling nodejs version 18.
dnf module enable nodejs:18 -y &>> $LOG_FILE
validateOperation $? "Enabling Nodejs:18"

# Installing Nodejs
dnf install nodejs -y &>> $LOG_FILE
validateOperation $? "Nodejs Installation"

# Create the user.
addUser "roboshop"

# Create app directory.
createDirectory "/app"

# Change to /app directory
cd /app

# Downloading the applicatio code.
curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip
validateOperation $? "Application code downloading"

# Unziping applicatino code.
unzip -o /tmp/cart.zip
validateOperation $? "Application code unzip in /app directory is:"

# Installing node package manager.
npm install
validateOperation $? "Node Package Manager downloading is:"

# Copying 'cart.service' to '/etc/systemd/system/' directory.
cp /home/Robo_Shop/service_files/Cart_service /etc/systemd/system/cart.service
validateOperation $? "cart.service file copied"

# Daemon-reload
systemctl daemon-reload
validateOperation $? "Daemon reload is:"

# Loading the cart.servie
systemctl enable cart.service
validateOperation $? "Cart.service enabled"

# Start cart.service
systemctl start cart.service
validateOperation $? "Cart.service started"



