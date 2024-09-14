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

installRedis(){
    # Update apt package.
    apt update -y &>> /dev/null

    # Install redis server.
    if ! command -v redis-cli; then
    echo " Redis isn't installed "

    echo "Installing redis...."
    apt install redis-server -y &>>/dev/null
    validateOperation $? "Redis installatino is "
    else
    redisVersion=$(redis-cli --version)
        echo "Redis already installed and version is: $redisVersion"
    fi

    # Modifying Redis configuration file and changing 127.0.0.0 ::1 to 0.0.0.0.
    sed -i 's/^bind 127.0.0.1 ::1/bind 0.0.0.0/' /etc/redis/redis.conf
    validateOperation $? "Modified IP address to 0.0.0.0 is: "

    
    # Daemon reload.
    systemctl daemon-reload
    validateOperation $? "Daemon is"

    # Starting redis.
    systemctl start redis
    validateOperation $? "Starting redis is"
    
    # Restarting Redis.
    systemctl restart redis
    validateOperation $? "Redis restart is "

    # Enabling redis.
     systemctl enable redis-server
    validateOperation $? "enabing redis is "
    
}

validateUser
installRedis




