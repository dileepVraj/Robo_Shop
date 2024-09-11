#!/bin/bash

LOG_FILE="/tmp/nginx.log"


# Readme:

# The Web/Frontend is the service in RoboShop to serve the web content over Nginx.
# This will have the web page for the web application.
# Developer has chosen Nginx as a web server and thus we will install Nginx Web Server.

#---------------------------------------------------------------------------------------

validateOperation() {
    if [ "$1" -eq 0 ];then
    echo "$2 is success"
    else
        echo "$2 is failed"
    fi
}

# Installing nginx.
apt install nginx -y &>> $LOG_FILE
validateOperation $? "Nginx installation"

# Enable nginx.
systemctl enable nginx
validateOperation $? "Enabling Nginx"

# Starting nginx.
systemctl start nginx
validateOperation $? "Nginx Start"

# Removing the default content(welcome code) that web-server(nginx) is serving.
rm -rf /usr/share/nginx/html/*
validateOperation $? "Removing default content"

# Downloading front end contend(html).
curl -L -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
validateOperation $? "Downloading front code"

# Change directory to /usr/share/nginx/html
cd /usr/share/nginx/html || exit
validateOperation $? "Changing directory to /usr/share/nginx/html is"

# Extract web.zip file.
unzip -o /tmp/web.zip
validateOperation $? "Extracting front end code"

# Adding reverse proxy to '/etc/nginx/sites-enabled' directory.
cp /home/Robo_Shop/service_files/NginxProxyConfig /etc/nginx/sites-enabled/roboshop.conf
validateOperation $? "Copying of nginx proxy file"




# Restarting Nginx.
systemctl restart nginx
validateOperation $? "Restarting Nginx"
