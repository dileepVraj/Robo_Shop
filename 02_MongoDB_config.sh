#!/bin/bash

Exit_Status=$?
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
WHITE=$(tput setaf 7)
LOG_FILE="/tmp/mongodb.log"
Mongo_Installation=$(command -v mongod)


validate_user() {
    if [ "$UID" -eq 0 ]; then
        echo -e "$GREEN""You are root user, good to install services.""$WHITE"
        
        read -p "Do you want to switch as root user? (yes/no): " response
        if [ "$response" = "yes" ]; then
            sudo su -
            validate_operation $Exit_Status "Switch to root user"
        fi

    else
        echo -e "$RED Only root users can install services, sorry 😒 $WHITE "
        exit 1
    fi
}


validate_operation(){
    if ! "$Exit_Status" ; then
        echo "$RED Sorry $2 failed $WHITE"
    elif [ $1 -eq 0 ]; then
        echo  "$GREEN yeah 👍 $2 success. $WHITE" 
    fi
}

check_and_install_gpg_key(){
    if ! command -v gpg &> /dev/null;then
    echo "$RED gnupg is not installed, Installing.... $WHITE"
    apt install gnupg -y
    echo "$GREEN gnupg installed successfully $WHITE"
    fi

}

import_mongo_db_gpg_key() {
    # URL of the MongoDB GPG key
    local key_url="https://www.mongodb.org/static/pgp/server-7.0.asc"
    
    # Destination path for the keyring
    local keyring_path="/usr/share/keyrings/mongodb-server-7.0.gpg"
    
    # Download and import the MongoDB GPG key
    curl -fsSL "$key_url" | sudo gpg -o "$keyring_path" --dearmor
    
    validate_operation $Exit_Status "MongoDB GPG key has been imported and stored at $keyring_path is"
}



create_list_file() {
    # MongoDB source list entry
    local list_entry="deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse"
    
    # Create the source list file
    echo "$list_entry" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    
    validate_operation $Exit_Status "MongoDB source list file has been created at /etc/apt/sources.list.d/mongodb-org-7.0.list is"
}

reload_package_database(){
    apt update -y
    validate_operation $Exit_Status "Package Update"

}

install_mongo_db_community_server(){
    validate_user
    apt install mongodb-org -y &> $LOG_FILE
    validate_operation $Exit_Status "MongoDB installation is"

    if [  "$Mongo_Installation" -eq 0 ]; then
        systemctl enable mongod
        validate_operation $Exit_Status "Enabling MongoDB is"
        systemctl start mongod
        validate_operation $Exit_Status "Mongodb start is"
    fi


}

modify_mongodb_selfBind_IP(){
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongo.conf
    validate_operation $Exit_Status "MongoDB Self_Bind modification is"
}

restart_mongoDB(){
    # restarting mongodb
    systemctl restart mongod
    validate_operation $? "mongo_DB restart is"
}


















