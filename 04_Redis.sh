#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
WHITE=$(tput setaf 7)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)


# Redis is used for in-memory data storage(Caching) and allows users to access the data of database over API.
validateOperation(){
    if [ $1 -eq 0 ];then
    echo "$GREEN $2 is successful$WHITE"
    else
        echo "$RED $2 is fail$WHITE"
    fi
}

updateAptPackage(){
    #Updating packages.
    echo "$CYAN updating apt packages $WHITE"
    apt update -y &> /dev/null
    validateOperation $? "Updating apt packages"
    
}

installRedis(){
    if command -v redis-server;then
    echo "$CYAN redis-server is already installed on your machine$WHITE"
    else
        echo "$CYAN redis-server isn't installed yet$WHITE"
        echo "$YELLOW installing redis-server$WHITE"
        apt install redis-server -y &> /dev/null
        if command -v redis-server;then
        echo "$GREEN successfully installed redis-server$WHITE"
        else
            echo "$RED somehow redis installation is failed $WHITE"
        fi
    fi
}

enableRedisServer(){
    echo "$CYAN Enabling redis-server $WHITE"
    systemctl enable redis-server
    validateOperation $? "Enabling redis-server"
}

startRedisServer(){
    echo "$CYAN Starting redis-server $WHITE"
    systemctl start redis-server
    validateOperation $? "Starting redis-server"
}


changeIpOfRedisServer(){
    # Usually Redis opens the port only to localhost(127.0.0.1), meaning this service can be accessed by 
    # the application that is hosted on this server only. However, we need to access this service to be 
    # accessed by another server, So we need to change the config accordingly.

    echo "$CYAN Modifying default IP: 127.0.0.1 to 0.0.0.0(public).$WHITE"
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
    validateOperation $? "Modifying Ip to public(0.0.0.0)"
}

restartRedisServer(){

    echo "$CYAN restarting redis-server $WHITE"
    systemctl restart redis-server
    validateOperation $? "restarting redis-server"
}

updateAptPackage
installRedis
enableRedisServer
startRedisServer
changeIpOfRedisServer
restartRedisServer






