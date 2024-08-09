#!/bin/bash

LOG_FILE="/tmp/mysql.log"

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



# Validating user.
validateUser

# CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version.
dnf module disable mysql -y &>> $LOG_FILE
validateOperation $? "Mysql version 8 is disabled"

# Copying mysql.repo to '/etc/yum.repos.d' directory.
cp /home/Robo_Shop/repo_files/mysql_repo /etc/yum.repos.d/mysql.repo
validateOperation $? "Copying of mysql.repo file is:"

# Installing Mysql server
dnf install mysql-community-server -y &>> $LOG_FILE
validateOperation $? "Mysql installation"

# Enabling Mysql
systemctl enable mysqld
validateOperation $? "Enabling Mysql"

# Starting MySql
systemctl start mysqld
validateOperation $? "MySql started"

# Changing root password in order to start using the database service.
mysql_secure_installation --set-root-pass RoboShop@1
validateOperation $? "Successfully changed root password of MySql"


