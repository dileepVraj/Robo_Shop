#!/bin/bash

ID=$(id -u)
LOG_FILE="/tmp/catalogue.log"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
WHITE=$(tput setaf 7)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)

#Developer has chosen the database MySQL. Hence, we are trying to install it up and configure it.


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

downloadAndInstallMysqlAPTRepo(){
    # To install MySQL Community Server, you first need to add the MySQL APT repository to your system.
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.26-1_all.deb
    validateOperation $? "Downloading & installing  MySql APT repository"
    echo "Downloaded MySql APT repository package"
    echo "Installing MySql APT package"
    dpkg -i mysql-apt-config_0.8.26-1_all.deb
    echo "Installed MySql APT package"


}

installingMySqlServer(){

    if command -v mysql-server;then
    echo "mysql-server is already installed on your machine"
    else
        echo "mysql-server isn't installed on your machine"
        echo "Installing mysql-server..."
        apt install mysql-server -y &> /dev/null
        validateOperation $? "Installing mysql-server"
    fi

}

secureMysqlInstallation(){
    echo "Securing mysql installation"
    mysql_secure_installation
    validateOperation $? "securing mysql installation"

}

checkStatus(){
    systemctl status mysql
}

loginToMySql(){
    mysql -u root -p

}

updateAptPackage
downloadAndInstallMysqlAPTRepo
installingMySqlServer
secureMysqlInstallation
checkStatus
loginToMySql

