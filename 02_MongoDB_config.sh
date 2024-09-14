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
        
        

    else
        echo -e "$RED Only root users can install services, sorry 😒 $WHITE "
        
        read -pr "Do you want to switch as root user? (yes/no): " response
        if [ "$response" = "yes" ]; then
            sudo su -
            validate_operation $Exit_Status "Switch to root user"
        else
            echo "You have choose to not switch as root user, we can't install packages, hence exiting"
            exit
        fi
    fi
}


validate_operation(){
    if [ "$Exit_Status" -ne 0 ]; then
        echo "$RED Sorry $2 failed $WHITE"
    elif [ $Exit_Status -eq 0 ]; then
        echo  "$GREEN yeah 👍 $2 success. $WHITE" 
    fi
}

check_and_install_gnupg(){

    # GnuPG (GNU Privacy Guard), often abbreviated as GPG, is a free and open-source software that 
    # implements the OpenPGP standard. It is used for secure encryption and digital signing of data 
    # and communications. GnuPG allows users to encrypt data and create digital signatures to ensure 
    # the integrity and confidentiality of files, emails, and other forms of digital communication.

    if ! command -v gpg &> /dev/null;then
    echo "$RED gnupg is not installed, Installing.... $WHITE"
    apt install gnupg -y
    echo "$GREEN gnupg installed successfully $WHITE"
    fi

}

import_mongo_db_gpg_key() {
    # If you don't import the GPG key for MongoDB on Ubuntu, you won't be able to install MongoDB 
    # successfully using the apt package manager. Here's why:

    # Why is the GPG Key Necessary?
    # Package Integrity: When you install MongoDB (or any software) from a third-party repository, 
    # the GPG key is used to verify the integrity and authenticity of the packages. 
    # It ensures that the packages come from the official MongoDB repository and have not been tampered 
    # with.

    # Trust Validation: Ubuntu's apt package manager requires a valid GPG key to trust the repository. 
    # Without importing the GPG key, apt will not be able to verify the source of the packages, and you 
    # will get an error when you try to install or update MongoDB.




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
    apt update -y &> /dev/null
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

check_and_install_gnupg
import_mongo_db_gpg_key
create_list_file
reload_package_database
install_mongo_db_community_server
modify_mongodb_selfBind_IP
restart_mongoDB



















