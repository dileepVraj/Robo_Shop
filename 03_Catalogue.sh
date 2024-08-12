#!/bin/bash

# storing user ID in a variable.
ID=$(id -u)
LOG_FILE="/tmp/catalogue.log"

validate_user() {
    if [ $ID -eq 0 ]; then
        echo "you are root user, good to install services"
    else
        echo "only root users can install servies sorry 😒"
    fi
}

validate_operation() {
    if [ $1 -ne 0 ]; then
        echo "Sorry $2 failed"
    elif [ $1 -eq 0 ]; then
        echo " yeah 👍 $2"
    fi
}


add_user() {
    # This function takes one positional parameter(username).
    # The 'id $1(positional parameter 1) returns response of user details if present, if not an error...
    # ..response along with the exit status.'

    # If 'id $1' fails the error response is supress to /dev/null directory where it will deleted input
    # automatically.

    if id "$1" &>/dev/null; then
        echo "Yes user '$1' exists."
    else
        echo "No user '$1' is not available"
        useradd "$1"
        echo "User '$1' is created."
    fi
}




createDirectory() {
    # This function takes 1 arguments, 1.path to directory we want create.

    # Usage of this function:
    # This function checks for a directory is present or not which is passed as argument.
    # If available it will prints directory is available message.
    # If directory is not available it will creates directory and prints the success message.
    
    # The '-d' option in bash is used within conditional expressions to test wheather a path is a directory.

    # The '-d' is typically used with 'test' command or within a '[' which is a synonym for 'test'.
    # It checks if given path exists and is a directory.
    if [ -d $1  ]; then
        echo "directory "$1" is available"
    else
        echo "directory "$1" is not available"
        # The option '-p' is used to create the parent directory if not exists,which specified in path.
        # Ex: mkdir -p /home/dileep/games this command creates 'games' directory in /home/dileep directory,
        # If /home/dileep is not present it will creates /home/dileep directory without failing the command.
        mkdir -p "$1"
        echo "directory "$1" is created"
        # changing to directory after creation if 'cd' command faile because no directory exists then program will
        # exists.
        # The '||' OR operator is used to execute the command following it only if preceding command fails(returns a non-zero exit status).
        cd "$1" || exit
        echo "changed to directory "$1" " 
    fi
}   









validate_user

#Disabling default nodejs module.
dnf module disable nodejs -y
validate_operation $? "NodeJS default 'module 10' is disabled"

#Enabling NodeJS version 18.
dnf module enable nodejs:18 -y
validate_operation $? "NodeJS 18 module is enabled."

#Installing NodeJS version 18.
dnf install nodejs -y &>> $LOG_FILE

#Capturing exit code in a variable after executing 'id <username> command which returns the exit code.'

add_user roboshop

# Changing directory to root.
cd /

# Verifying do '/app' directory is available or not and if not create one.
createDirectory "/app"

# Downloading 'catalogue' application code to /tmp directory.
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

# unziping the downloaded catalogue.zip file in /app directory.
unzip -o /tmp/catalogue.zip

# installing npm package manager for nodejs packages.
npm install &>> $LOG_FILE
validate_operation $? "npm installed"

# adding catalogue.service file in /etc/systemd/system/ directory.
cp /home/Robo_Shop/service_files/Catalogue_service /etc/systemd/system/catalogue.service
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
cp /home/Robo_Shop/repo_files/mongodb_repo /etc/yum.repos.d/mongo.repo
validate_operation $? "mongo.repo file created"

# Installing mongodb shell(client)
dnf install mongodb-org-shell -y &>> $LOG_FILE
validate_operation $? "Mongo_DB client installed successfully"

# Loading schema to mongodb from catalogue 'ms' 
mongo --host 172.31.43.180 </app/schema/catalogue.js
validate_operation $? "Successfully loaded catalogue schema to mongo_db"
