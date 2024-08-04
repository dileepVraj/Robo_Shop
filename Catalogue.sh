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

add_user() {
    if [ $1 -ne 0 ]; then
        echo "No user called '$2' exists."
        useradd $2
        echo "User '$2' added successfully."
    else
        echo "User '$2' is already exists."
    fi

}


createDirectory() {
    # This function takes 2 arguments, 1.path to directory we want to check if it exists.
    # 2. if not the path we want to create a directory in, with directory name.
    if [ test -d /$1 -eq 0 ]; then
        echo "directory $1 is available"
    else
        echo "directory $1 is not available"
        mkdir $2
        echo "directory $2 is created"
        cd $2
        echo "changed to directory $2"
}


#disabling default nodejs module.
dnf module disable nodejs -y
validate_operation $? "NodeJS default 'module 10' is disabled"

#Enabling NodeJS version 18.
dnf module enable nodejs:18 -y
validate_operation $? "NodeJS 18 module is enabled."

#Installing NodeJS version 18.
dnf install nodejs -y

# capturing exit code in a variable after executing 'id <username> command which returns the exit code.'
id roboshop
IsUserExists=$($?)
add_user $? roboshop

# Changing directory to root.
cd /

# Verifying do '/app' directory is available or not and if not create one.
createDirectory "app" "/app"









