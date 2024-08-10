#!/bin/bash
LOG_FILE="/tmp/rabbitMq.log"

# Readme:
# RabbitMQ is a messaging Queue which is used by some components of the applications.
#-------------------------------------------------------------------------------------


validateOperation() {
    if [ $1 -eq 0 ];then
    echo "$2 is success"
    else
        echo "$2 is failed"
    fi
}

# Settingup RabbitMQ Erlang repository on our system.
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
validateOperation $? "RabbitMQ repository setup"

# Configuring YUM repos for RabittMq.
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
validateOperation $? "Configuration of YUM repos"

# Installing RabittMq
dnf install rabbitmq-server -y 
validateOperation $? "Installation of RabittMq"


# Starting RabittMq service.
systemctl enable rabbitmq-server 
validateOperation $? "Enabled RabittMq"


# Starting RabittMq service.
systemctl start rabbitmq-server
validateOperation $? "Started RabittMq"

#--------------------------------------------------------------

# RabbitMQ comes with a default username / password as guest/guest.
# But this user cannot be used to connect. Hence, we need to create one user for the application.

#---------------------------------------------------------------

# Creating user.
rabbitmqctl add_user roboshop roboshop123
validateOperation $? "Creating new RabittMq user"

# setting permissions for created user.
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validateOperation $? "Setting Permissions for user"



# 

