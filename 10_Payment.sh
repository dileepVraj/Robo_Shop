#!/bin/bash
LOG_FILE="/tmp/payment.log"

# Readme:

# This service is responsible for payments in RoboShop e-commerce app.
# This service is written on Python 3.6, So need it to run this app.

#----------------------------------------------------------

# This application is developed using Python.
validateOperation() {
    if [ $1 -eq 0 ];then
    echo "$2 is success"
    else
        echo "$2 is failed"
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
}





# Install Python(3.6).
dnf install python36 gcc python3-devel -y &>> $LOG_FILE
validateOperation $? "Python(3.6) installation"

# Create a user
userAdd "roboshop"

# Creating app directory.
createDirectory "/app"

# Downloading the application code.
curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip
validateOperation $? "Application code download"

# Change to application directory.
cd /app
validateOperation $? "Change to application directory"

# Unziping application code.
unzip -o /tmp/payment.zip
validateOperation $? "Unzipping application code"

# Downloading dependencies.
pip3.6 install -r requirements.txt
validateOperation $? "Downloading dependencies is"

# Copying or moving payment.service to /etc/systemd/system directory.
cp /home/Robo_Shop/service_files/Payment_service /etc/systemd/system/payment.service
validateOperation $? "Moving Payment_service"

# Reload the daemon.
systemctl daemon-reload
validateOperation $? "Daemon reload"

# Enabling payment.service
systemctl enable payment.service
validateOperation $? "Enabling payment.service"

# Starting payment.service
systemctl start payment.service
validateOperation $? "Starting payment.service"






