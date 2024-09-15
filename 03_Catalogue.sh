#!/bin/bash

# storing user ID in a variable.
ID=$(id -u)
LOG_FILE="/tmp/catalogue.log"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
WHITE=$(tput setaf 7)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)

# notes(){
    # Notes:

    # How to insatall nodejs 18 on ubuntu ec2 instance.

    # To install nodejs 18 on ubuntu ec2 instance, we will be using Node.js repository, which makes it easy to install the lates
    #.. version of Node.js

    # Steps to insatall:

    # Update package list: apt update -y
    # Install curl: apt install curl -y
    # Add NodeSource Node.js 18 repository: Use the following command to add the NodeSource repository for Node.js 18.x.

    # Command: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        # Breakdown:
        # ---------
            # The command downloads a Node.js setup script from https://deb.nodesource.com/setup_18.x using curl. 
            # The options used (-fsSL) ensure that the download process is silent but still shows errors and follows any redirects.
            # The downloaded script is then passed directly to bash via a pipe, where bash executes the script with superuser 
            # privileges (sudo). The -E option makes sure environment variables are preserved during this process.
    # Insatll Node.js" apt install nodejs -y
    # Verify the Node.js installation: node -v
    # build essentials: apt install build-essential -y

# }






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
        echo "$GREEN yes 👍 $2 is success $WHITE"
    fi
}


# Takes 1 argument 'username' to be created.
add_user() {
    # This function takes one positional parameter(username).
    # The 'id $1(positional parameter 1) returns response of user details if present, if not an error...
    # ..response along with the exit status.'

    # If 'id $1' fails the error response is supress to /dev/null directory where it will deleted input
    # automatically.

    if id "$1" &>/dev/null; then
        echo "$BLUE Yes user '$1' exists.$WHITE"
    else
        echo "$RED No user '$1' is not available.$WHITE"
        useradd "$1"
        echo "$GREEN User '$1' is created.$WHITE"
    fi
}



# Takes 1 argument directory path to be create.
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
        echo "$GREEN directory "$1" is created.$WHITE"
        # changing to directory after creation if 'cd' command faile because no directory exists then program will
        # exists.
        # The '||' OR operator is used to execute the command following it only if preceding command fails(returns a non-zero exit status).
        cd "$1" || exit
        echo "$BLUE changed to directory $1 $WHITE" 
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
        echo "$YELLOW Installing curl... $WHITE"
        apt install curl -y &>> $LOG_FILE
        validate_operation $? "Curl installation is"
        else
            echo "$RED Curl installation is failed... $WHITE"
        fi
    else
        echo "$BLUE Curl utility already installed on your machine..$WHITE"

    fi

    # downloading NodeSource Node.js 18 repository.
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &>> $LOG_FILE
    validate_operation $? "NodeSource repository downloaded successfully"

    if command -v node &> /dev/null;then
    echo "$BLUE Nodejs already installed on your machine$WHITE"
    else
        echo "$BLUE Nodejs ins't installed on your machine$WHITE"
        # Installing Node.js.
        echo "$YELLOW installing Nodejs...$WHITE"
        apt install nodejs -y &>> $LOG_FILE
        validate_operation $? "Node.js installation "

        # Verifying is Node.js installed.
        NodejsCheck=$(node -v)
        if [ $NodejsCheck = "v18.20.4" ]; then
        echo "$GREEN Node.js is installed successfully $WHITE"
        else
            echo "$RED Failed to install Node.js $WHITE"
        fi
    fi
    
}

downloadingApplicationCode(){
    # Downloading 'catalogue' application code to /tmp directory.
    curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
    validate_operation $? "Application code is downloaded successfully."

}

unzipTheApplicationCode(){
    # This function is to unzip application code in /app directory , we using option '-o'
    # ....to override if any same files exists in the directory.

    if ! command -v unzip; then
    echo "$RED unzip isn't installed do you want to install yes/no $WHITE"
    read -r response
        if [ $response = "yes" ];then
        echo "$YELLOW installing unzip utility... $WHITE"
        apt install unzip -y
        validate_operation $? "unzip utility installation is"
        else
            echo "unzip utility already installed"
        fi
    fi

    # unziping the downloaded catalogue.zip file in /app directory.
    unzip -o /tmp/catalogue.zip
    validate_operation $? "Unziping application code in 'tmp/catalogue.zip'"

}


installNPM(){

    if command -v npm &> /dev/null; then
    echo "$BLUE npm already installed on your machine...$WHITE"
    else
        echo "$BLUE npm isn't installed yet on your machine$WHITE"
        # installing npm package manager for nodejs packages.
        echo "$YELLOW installing npm...$WHITE"
        npm install &>> $LOG_FILE
        validate_operation $? "npm installation is"

    fi
    
}

creatingServiceFile(){
    # adding catalogue.service file in /etc/systemd/system/ directory.
    cp /home/Robo_Shop/service_files/Catalogue_service /etc/systemd/system/catalogue.service
    validate_operation $? "catalogue.service is created"
}

daemonRestart(){
    # Restarting the system daemon.
    systemctl daemon-reload
    validate_operation $? "daemon reloaded good to go.."

}

startingCatalogue(){
    # Start catalogue service.
    systemctl enable catalogue
    validate_operation $? "Catalogue enabled"
    systemctl start catalogue
    validate_operation $? "Catalogue started"

}

installingMongodbShell(){

    if command -v mongosh &> /dev/null;then
    echo "$BLUE mongosh already installed on your machine $WHITE"
    else

        # Installing shell.
        wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
        echo "$YELLOW Updating apt packages...$WHITE"
        sudo apt update &>> /dev/null
        echo "$YELLOW installing mongodb_shell...$WHITE"
        apt install mongodb-mongosh -y &>> $LOG_FILE
        validate_operation $? "Mongodb Shell installation is successfull"
        shellVersion=$(mongosh --version)
        echo " $GREEN Mongodb shell version is $shellVersion $WHITE"
    fi
}

# Takes 1 argument (IP address of MONGO_DB instance.)
loadingCatalogueSchema(){
    # Loading schema to mongodb from catalogue 'ms' 
    mongosh --host $1 </app/schema/catalogue.js &> /dev/null
    validate_operation $? "Successfully loaded catalogue schema to mongo_db"


}

validate_user

install_Node.js

add_user "roboshop"

createDirectory "/app"

downloadingApplicationCode

unzipTheApplicationCode

installNPM

creatingServiceFile

daemonRestart

startingCatalogue

installingMongodbShell

loadingCatalogueSchema "172.31.36.157"










