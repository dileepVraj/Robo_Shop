#!/bin/bash

validate_user() {
    if [ $ID -eq 0 ]; then
        echo "you are root user, good to install services"
    else
        echo "only root users can install servies sorry 😒"

        echo " Do you want to switch to root user? enter yes/no"

        read -r response

        if [ $response = "yes" ];then
        sudo su -
        validate_operation $? "Switching as root user is"
        fi
        
    
    fi
}

validate_operation(){
    if [ $1 -ne 0 ]; then
        echo " $RED Sorry $2 failed $WHITE"
    else
        echo "$GREEN yes 👍 $2 $WHITE"
    fi
}

# Takes one argument <username> to create.
add_user() {
    # This function takes one positional parameter(username).
    # The 'id $1(positional parameter 1) returns response of user details if present, if not an error...
    # ..response along with the exit status.'

    # If 'id $1' fails the error response is supress to /dev/null directory where it will deleted input
    # automatically.

    if id "$1" &>/dev/null; then
        echo "Yes user '$1' exists."
    else
        echo "No user '$1' is not available"
        useradd "$1"
        echo "User '$1' is created."
    fi
}

# takes 1 argument 'path to create a directory'. 
createDirectory() {
    # This function takes 1 arguments, 1.path to directory we want create.

    # Usage of this function:
    # This function checks for a directory is present or not which passed as argument.
    # If available it will prints directory is available message.
    # If directory is not available it will creates directory and prints the success message.
    
    # The '-d' option in bash is used within conditional expressions to test wheather a path is a directory.

    # The '-d' is typically used with 'test' command or within a '[' which is a synonym for 'test'.
    # It checks if given path exists and is a directory.
    if [ -d $1  ]; then
        echo "directory "$1" is available"
    else
        echo "directory "$1" is not available"
        # The option '-p' is used to create the parent directory if not exists,which specified in path.
        # Ex: mkdir -p /home/dileep/games this command creates 'games' directory in /home/dileep directory,
        # If /home/dileep is not present it will creates /home/dileep directory without failing the command.
        mkdir -p "$1"
        echo "directory "$1" is created"
        # changing to directory after creation if 'cd' command faile because no directory exists then program will
        # exists.
        # The '||' OR operator is used to execute the command following it only if preceding command fails(returns a non-zero exit status).
        cd "$1" || exit
        echo "changed to directory "$1" " 
    fi
}   

install_Node.js(){
    # updating package list.
    apt update -y &>> /dev/null
    echo "$GREEN Updated package list $WHITE"

    # verify is curl installed.
    if ! command -v curl; then
    echo "$RED curl isn't installed, do you want to install it? yes/no"
    read -r response
        if [ $response = "yes" ];then
        echo "$GREEN Installing curl... $WHITE"
        apt install curl -y &>> $LOG_FILE
        validate_operation $? "Curl installation is"
        else
            echo "$RED Curl installation is failed... $WHITE"
        fi

    fi

    # downloading NodeSource Node.js 18 repository.
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &>> $LOG_FILE
    validate_operation $? "NodeSource repository downloaded successfully"

    # Installing Node.js.
    apt install nodejs -y &>> $LOG_FILE
    validate_operation $? "Node.js installation is successfull"

    # Verifying is Node.js installed.
    NodejsCheck=$(node -v)

    if [ $NodejsCheck = "v18.20.4" ]; then
    echo "$GREEN Node.js is installed successfully $WHITE"
    else
        echo "$RED Failed to install Node.js $WHITE"
    fi

    
}


downloadingApplicationCode(){
    # Downloading 'catalogue' application code to /tmp directory.
    curl -L -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/user.zip
    validate_operation $? "Application code is downloaded successfully."

}

unzipTheApplicationCode(){
    # This function is to unzip application code in /tmp in /app directory , we using option '-o'
    # ....to override if any same files exists in the directory.

    if ! command -v unzip; then
    echo "$RED unzip isn't installed do you want to install yes/no $WHITE"
    read -r response
        if [ $response = "yes" ];then
        apt install unzip -y
        validate_operation $? "unzip utility installation is"
        else
            echo "unzip utility already installed"
        fi
    fi

    # unziping the downloaded catalogue.zip file in /app directory.
    unzip -o /tmp/catalogue.zip
    validate_operation $? "Unziping application code in 'tmp/user.zip'"

}

installNPM(){
    # installing npm package manager for nodejs packages.
    npm install &>> $LOG_FILE
    validate_operation $? "npm installation is"
}

creatingServiceFile(){
    # adding catalogue.service file in /etc/systemd/system/ directory.
    cp /home/Robo_Shop/service_files/User_service /etc/systemd/system/user.service
    validate_operation $? "catalogue.service is created"
}

daemonRestart(){
    # Restarting the system daemon.
    systemctl daemon-reload
    validate_operation $? "daemon reloaded good to go.."

}

startingUser(){
    # Start catalogue service.
    systemctl enable user
    validate_operation $? "user enabled"
    systemctl start user
    validate_operation $? "user started"

}

installingMongodbShell(){
    # Installing shell.
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt update &>> /dev/null
    apt install mongodb-mongosh -y &>> $LOG_FILE
    validate_operation $? "Mongodb Shell installation is successfull"
    shellVersion=$(mongosh --version)
    echo " $GREEN Mongodb shell version is $shellVersion $WHITE"
}

# Takes 1 argument (IP address of MONGO_DB instance.)
loadingUserSchema(){
    # Loading schema to mongodb from catalogue 'ms' 
    mongosh --host $? </app/schema/user.js
    validate_operation $? "Successfully loaded user schema to mongo_db"


}

install_Node
add_user "roboshop"
createDirectory "/app"
downloadingApplicationCode
installNPM
creatingServiceFile
daemonRestart
startingUser
installingMongodbShell
loadingUserSchema ""




