#!/bin/bash

ID=$(id -u)
LOG_FILE="/tmp/Redis.log"


validateUser() {
    if [ $ID -ne 0 ]; then
    echo "Sorry you are not a root user, only root user can install services"
    else
        echo "Welcome to Redis service configuration"
    fi
    
}

validateOperation() {
    if [ $1 -ne 0 ];then
    echo "Operation $2 failed."
    exit 1
    else 
        echo "Operation $2 success."
    fi
}

# This function takes only placeholder parameter 'username'.
addUser() {
    if id "$1" &>/dev/null;then
    echo "Yes user "$1" exists."
    else
        echo "No user "$1" is not available."
        useradd "$1"
        echo "New user "$1" is created."
    fi

}

createDirectory(){
    if [ -d $1 ]; then
    echo "Directory '$1' is available."
    else
        echo "Directory '$1' is not available"
        mkdir -p "$1"
        echo "Directory '$1' is created successfully."
    fi  
}

# validating user
validateUser

# Installing Redis repo file as RPM.
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> "$LOG_FILE"
validateOperation $? "Redis repo file downloaded"

# Enabling Redis 6.2 from package streams.
dnf module enable redis:remi-6.2 -y &>> $LOG_FILE
validateOperation $? "Enabling Redis package streams 6.2 is"

# Installing 'Redis'.
dnf install redis -y &>> $LOG_FILE
validateOperation $? "Redis installation"

# Updating the listning address from '127.0.0.1' to 0.0.0.0 in /etc/redis.conf /etc/redis/redis.conf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
validateOperation $? "Bind address 127.0.0.1 is changed to 0.0.0.0"

# Enabling redis
systemctl enable redis
validateOperation $? "Redis enabling"

# Starting redis
systemctl start redis 
validateOperation $? "Redis_start"
