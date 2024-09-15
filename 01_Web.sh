#!/bin/bash

LOG_FILE="/tmp/nginx.log"
Exit_Status=$?
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
WHITE=$(tput setaf 7)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)

# notes(){
    # Readme:

    # The Web/Frontend is the service in RoboShop to serve the web content over Nginx.
    # This will have the web page for the web application.
    # Developer has chosen Nginx as a web server and thus we will install Nginx Web Server.

    #---------------------------------------------------------------------------------------


    # Guide to commands:
    #-------------------

    # 1. '&>>' In Linux '&>>' is used to redirect both standard output and standard error to the same file
    #.. appending output to the file.

    # Here is how it works:
    #----------------------

    # '&>>' is short hand for: '1>>' for appending standard output to a file.
    # '2>>' for appending standard error to the same file.

    # So, '&>>' combines both into one command that appends both streams (standard output and error) to a file.

    # command "&>> output.log".

    # ------------------------------------------------------------------------------------------------------

    # 2. command -v:

    # The command -v is used in Linux to check wheather a command or executable is available in the system
    # and where it is located.

    # Breakdown:

    # 'command': A shell built-in that executes commands.
    # '-v': an option that prints path of the command or executable if it exists, or nothing if it does not.
    #-----------------------------------------------------------------------------------------------------

    # 3. '&>': redirects both standard output and error to same file, and overwrites the file, unlike &>> which
    # appends.
    #-----------------------------------------------------------------------------------------------------
    # 4. '/dev/null'

    # In Linux, '/dev/null' is a special device file that discards all data written to it. It is also known
    # .. as "null device" or "bit bucket". Essentially it is a black hole where any data sent to it simply 
    # discarded. 

    # Why to use '/dev/null':

    # Suppress output: Sometimes you don't care about the output or errors of a command, and you just want to run it silently.
    # Logging: In scripts, you may only want to log specific output and discard everything else.
    #-----------------------------------------------------------------------------------------------------

    # 5. curl: The command line tool for making HTTP requests and downloading / uploading data via various 
    # protocols like HTTP, HTTPS, FTP, etc.

    # '-L': -L option tells curl to follow redirects. if the URL you are requesting has been redirected to another
    # URL(e.g, moved permanently ore temporarily) curl will follow the redirection and request the final URL.

    # '-o': This option allows you to specify the output file name. Instead of printing the name to the terminal
    # curl saves the output to specified file.

    #-----------------------------------------------------------------------------------------------------

    # 6. /etc/nginx/sites-enabled/:

    # The sites-enabled directory in /etc/nginx/ in Ubuntu (and other Linux distributions) is a part of nginx
    # configuration management system.

    # It is used to store symlinks to actual site congifuratin file.

    # Here’s a breakdown of its purpose and how it fits into Nginx's structure:

    # /etc/nginx/sites-enabled/: This directory holds symbolic links to actul configuration files that define
    # which websites nginx serves.

    # /etc/nginx/sites-available/: This directory actually contains the actual configuration files for your
    # Nginx virtual hosts(websites).

    # Purpose of sites-enabled:

    # The files in the sites-enabled directory are active site configurations that Nginx will load when it starts.
    # These files are typically symlinks (symbolic links) pointing to the actual configuration files located 
    # in the sites-available directory.

    # Why Use sites-available and sites-enabled?

    # This setup allows you to easily manage multiple websites on a single server, by enabling or disabling 
    # sites without actually deleting their configuration files.

    # * /etc/nginx/sites-available/ contains all available site configurations, including ones that might 
    # not be active.

    # * /etc/nginx/sites-enabled/ contains only the configurations that are currently enabled and will be 
    # served by Nginx.

    # Example:
    # You create a website configuration file, mywebsite.com, in the /etc/nginx/sites-available/ directory.
    # To enable the website, you create a symlink from mywebsite.com in sites-available to sites-enabled:

    # sudo ln -s /etc/nginx/sites-available/mywebsite.com /etc/nginx/sites-enabled/

    # Now, the website will be live after you reload or restart Nginx.

    # sudo systemctl reload nginx

    # Disabling a Site:

    # If you want to disable a site, you simply remove the symlink from the sites-enabled directory:

    # sudo rm /etc/nginx/sites-enabled/mywebsite.com

    # This doesn't delete the actual configuration file in sites-available, so you can re-enable the site 
    # later if needed by re-creating the symlink.
    #-----------------------------------------------------------------------------------------------------

# }

validateOperation() {
    # function that two arguments 1. exit code status($?) and operation name and checks if exit code is
    #.. zero if yes then prints success message of operation we specified, if not failed message of operation.
    if [ "$1" -eq 0 ];then
    echo "$GREEN $2 is success😊 $WHITE"
    else
        echo "$RED $2 is failed🤔 $WHITE"
    fi
}

install_Nginx(){
    # Checks if Nginx is exists in system, if not it installs Nginx, if already exists then prints
    # appropriate message, that nginx is installed.


    if ! command -v nginx &> /dev/null;then
        ehco "$CYAN Nginx isn't installed.$WHITE"

        echo "$YELLOW Installing Nginx ...$WHITE"
        apt install nginx -y &>> $LOG_FILE
        validateOperation "$Exit_Status" "Nginx installation"


        # Enabling Nginx.
        systemctl enable nginx
        validateOperation "$Exit_Status" "Enabling Nginx"

        # Starting nginx.
        systemctl start nginx
        validateOperation "$Exit_Status" "Starting Nginx"

    else
        echo " $GREEN Nginx already installed 😊. $WHITE"
    fi

}

remove_default_nginx_files(){
    # Notes:
    # Removing the default content(welcome code) that web-server(nginx) is serving, located in
    #.. /usr/share/nginx/html/.

    rm -rf /usr/share/nginx/html/*
    validateOperation "$Exit_Status" "Removing default Nginx files"
}

download_frontEndCode(){

    # Downloading front end contend(html).
    curl -L -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &> /dev/null
    validateOperation "$Exit_Status" "Downloading front code"

}

unzip_frontEndCode(){

    # Change directory to /usr/share/nginx/html
    cd /usr/share/nginx/html || exit
    currentDirectory=$(pwd)
    if [ $currentDirectory = "/usr/share/nginx/html" ];then
    echo "$GREEN successfully changed to /usr/share/nginx/html directory.$WHITE"
    else
        echo "$RED change directory to /usr/share/nginx/html some how isn't happened.$WHITE"
    fi
    validateOperation "$Exit_Status" "Changing directory to /usr/share/nginx/html is"

    # Verifying and installing Unzip utility.
    if ! command -v unzip &> /dev/null; then
        echo "$RED Unzip utility isn't installed yet. $WHITE"
        echo "$YELLOW Installing Unzip... $WHITE"
        apt install unzip &> /dev/null
        validateOperation "$Exit_Status" "Unzip utility installation"

        # Unzipping web.zip 
        unzip -oq /tmp/web.zip
        validateOperation "$Exit_Status" "Extracting front end code"
    else
        echo "$GREEN Unzip utility already installed $WHITE"
        if [ $currentDirectory = "/usr/share/nginx/html" ];then
        echo "$GREEN successfully changed to /usr/share/nginx/html directory.$WHITE"
        else
            echo "$RED change directory to /usr/share/nginx/html some how isn't happened.$WHITE"
        fi
        unzip -oq /tmp/web.zip
        # unzip is utility in Linux, used to extract compressed files from .zip archive.
        # -o: This option tells unzip to overwrite any existing files in the destination directory if 
        # ..they have the same name as the files being extracted from the archive.
        validateOperation "$Exit_Status" "Extracting front end code"
    fi
}

settingUpReverseProxy(){

    # Copying 'NginxProxyConfig' file to /etc/nginx/sites-enabled/ directory as 'roboshop.conf'
    cp /home/Robo_Shop/service_files/NginxProxyConfig /etc/nginx/sites-enabled/roboshop.conf
    if [ -f "/etc/nginx/sites-enabled/roboshop.conf" ];then
    echo "$GREEN Successfully created roboshop.conf file 😊 $WHITE"
    else
        echo "$RED Somehow failed to create roboshop.conf file 🤔 $WHITE"
            
        # Removing 'default' directory in /etc/nginx/sites-enabled.

        # In the /etc/nginx/sites-enabled/ directory, the default file is a default configuration file 
        # provided by Nginx. It typically contains a basic configuration for a default server block 
        # (or virtual host) that Nginx uses if no other server blocks match a request.

        echo "$CYAN Removing default configuration of Nginx.$WHITE"
        rm -r /etc/nginx/sites-enabled/default
        validate_operation $? "Removing default config directory is"
    fi

}

restartNginx(){
    # Restarting Nginx.
    systemctl restart nginx
    validateOperation "$Exit_Status" "Restarting Nginx"
}

install_Nginx
remove_default_nginx_files
download_frontEndCode
unzip_frontEndCode
settingUpReverseProxy
restartNginx





