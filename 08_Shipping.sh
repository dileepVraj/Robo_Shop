#!/bin/bash
ID=$(id -u)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
WHITE=$(tput setaf 7)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)

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
        echo "$BLUE creating $1 user$WHITE"
        useradd "$1"
        echo "$GREEN User '$1' is created.$WHITE"
    fi
}

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
        echo "$GREEN directory $1 is available $WHITE"
    else
        echo "$CYAN directory $1 is not available $WHITE"
        # The option '-p' is used to create the parent directory if not exists,which specified in path.
        # Ex: mkdir -p /home/dileep/games this command creates 'games' directory in /home/dileep directory,
        # If /home/dileep is not present it will creates /home/dileep directory without failing the command.
        echo "$YELLOW creating directory $WHITE"
        mkdir -p $1
        echo "$GREEN directory /app created successfully.$WHITE"
        
    fi
}   

installMaven(){
    if command -v mvn &> /dev/null;then
    echo "Maven is installed"
    echo "Maven version:"
    mvn -version
    return 0
    else
        echo "Maven is not installed or not in path"
        echo "Installing maven..."
        apt install maven -y
        validateOperation $? "Installing maven"
    fi


}

downloadingApplicationCode(){
    # Downloading 'shipping' application code to /tmp directory.
    curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &> /dev/null
    validate_operation $? "Downloading application code"

}

unzipTheApplicationCode(){
    # This function is to unzip application code in /app directory , we using option '-o'
    # ....to override if any same files exists in the directory.

    if ! command -v unzip; then
    echo "$RED unzip isn't installed do you want to install yes/no $WHITE"
    echo "$YELLOW installing unzip utility... $WHITE"
    apt install unzip -y &> /dev/null
    validate_operation $? "unzip utility installation is"
    else
        echo "unzip utility already installed"
        
    fi

    # changing to directory after creation if 'cd' command faile because no directory exists then program will
    # exists.
    # The '||' OR operator is used to execute the command following it only if preceding command fails(returns a non-zero exit status).
    cd "/app" || exit
    echo "$BLUE changed to directory /app $WHITE" 

    # unziping the downloaded catalogue.zip file in /app directory.
    unzip -oq unzip /tmp/shipping.zip
    validate_operation $? "Unziping application code in 'tmp/shipping.zip is'"

}

cleanMavenPackage(){
    echo "Cleaning maven package..."
    mvn clean package &> /dev/null

    

}

renameShippingJar(){

    mv target/shipping-1.0.jar shipping.jar
    echo "Renamed shippingJar"
}

creatingServiceFile(){
    # adding shipping.service file in /etc/systemd/system/ directory.
    cp /home/Robo_Shop/service_files/Shipping_service /etc/systemd/system/shipping.service
    validate_operation $? "shipping.service is created"
}

daemonReload(){
    systemctl daemon-reload
    echo "Daemon reloaded successfully"
}

enableAndStartShippingService(){
    systemctl enable shipping 
    systemctl start shipping
}

InstallMySqlClient(){
    echo "Updateing packages"
    apt update -y &> /dev/null

    echo "installing mysql client"
    apt install mysql-client -y &> /dev/null

}

loadSchemaToMySqlServer(){
    echo "Loading schema of shipping addresses to mysql database"
    mysql -h $1 -uroot -pdileep1# < /app/schema/shipping.sql 
    echo "Successfully loaded schema to mysql-server"

    echo "Restarting shipping"
    systemctl restart shipping


}

updateAptPackage
add_user "roboshop"
createDirectory "/app"
installMaven
downloadingApplicationCode
unzipTheApplicationCode
cleanMavenPackage
renameShippingJar
daemonReload
enableAndStartShippingService
InstallMySqlClient
loadSchemaToMySqlServer "172.31.36.197"
















