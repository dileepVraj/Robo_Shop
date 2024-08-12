#!/bin/bash

LOG_FILE="/tmp/service.log"

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

# Shipping service is responsible for finding the distance of the package to be shipped and calculate the price based on that.

# Shipping service is written in Java, Hence we need to install Java.

# Maven is a Java Packaging software, Hence we are going to install maven, This indeed takes care of java installation.

# ==================================================================================================#

# Installing Maven.
dnf install maven -y

# Configure the application, adding user.
addUser "roboshop"

# Crating application directory.
createDirectory "/app"

# Changing to '/app' directory.
cd /app
validateOperation $? "Changed to directory /app"

# Downloading application code to /tmp directory.
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
validateOperation $? "Appliacation Download"

# unziping application code in /app directory.
unzip -o /tmp/shipping.zip
validateOperation $? "Application code unziped"

# Every application is developed by development team will have some common softwares that they use as libraries. 
# This application also have the same way of defined dependencies in the application configuration.
#--------------------------------------------


# installing maven package.
mvn clean package &&> $LOG_FILE
validateOperation $? "Maven package installation"

# Re-naming 'shipping-1.0.jar' to shipping.jar
mv target/shipping-1.0.jar shipping.jar
validateOperation $? "Renamed shipping-1.0 to shipping.jar"

# We need to setup a new service in systemd so systemctl can manage this service
#--------------------------------------------

# Copying shipping_servie to /tmp/systemd/system directory
cp /home/Robo_Shop/service_files/Shipping_service /etc/systemd/system/shipping.service
validateOperation $? "creating shipping.service file"

# Daemon-reload
systemctl daemon-reload
validateOperation $? "Dameon reload"

# enabling shipping.service
systemctl enable shipping
validateOperation $? "Enabling shipping.service"

# Starting shipping.service
systemctl start shipping
validateOperation $? "Starting shipping.service"

# For this application to work fully functional we need to load schema to the Database.
# We need to load the schema. To load schema we need to install mysql client.
# To have it installed we can use.
#-----------------------------------

# Installing mysql client.
dnf install mysql -y
validateOperation $? "Mysql client install"

# Loading shipping schema to mysql database.
mysql -h 172.31.32.21 -uroot -pRoboShop@1 < /app/schema/shipping.sql
validateOperation $? "Successfully loaded schema to MySql database"

# Restarting shipping.service
systemctl restart shipping
validateOperation $? "Restart shipping.service"








