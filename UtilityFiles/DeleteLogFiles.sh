#!/bin/bhas

# Algorithm.

# Identify directory where .log files are stored.
# Delete log files which are older than user specified time.

Source_dir="/home/shell/"

# Verify do folder exists or not if not throw some error or warning message.

verifyDirExistance() {
    if [ -d $Source_dir ]; then
    echo " Directory $Source_dir is available "
    else
        echo " Direcory $Source_dir is not available"
    fi
}

# Let's create different types of files in '/tmp/shellScript_logs' directory.
    # Let's create some files with previous date time stamp.
    # We can create files without time using '-d' opiton in YYYYMMDD format.

# This function takes two arguments(timestamp and file name.)
createFiles() {
    mkdir -p $Source_dir
    touch -t $1 $Source_dir$2
    if [ -f "/home/shell/$2" ];then
    echo "Successfully created file $2"
    else
        echo "Failed to create file $2"
    fi


}

verifyDirExistance
# createFiles "202407301420" "sample.log"
# createFiles "202407301420" "sample1.log"
# createFiles "202407301420" "sample2.txt"
# createFiles "202407301420" "sample3.txt"

# Now we need to find files which are older than user specified time or date.

    # We can use 'find' command to locate files that are older than a specific time or date.
    # Syntax: 'find /path/to/directory -type f -mtime +N' 

    # Breakdown: '/path/to/directory' The directory where we want to serach for files.
    # '-type f': Restricts the search to files (not directories)
    # '-mtime +N': Finds files modified more than N days ago.

    # Example: To find files older than 30 days
    # Command: find /home/shell -type f -mtime +30

    #** To find files older than a specific Number of Minutes.
    # Command: find /home/shell -type f -mmin +N
    # Example: find /home/shell -type f -mmin +60

    # If we want to filter files using extension then we can use below command.
        # find <path to directory> -type -f -mtime +N -name "*.log"

        # The above command lists .log files that are older than specified time.


# This function takes 3 arguments (path to directory where files are listed, time(date) and file type)
listFilesToDelete() {
    FilesToDelete=$(find $1 -type f -mtime +"$2" -name "*.$3")
}

listFilesToDelete "/home/shell" "10" "log"

echo "$FilesToDelete"






