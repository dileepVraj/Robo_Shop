#!/bin/bash

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

# Note:
    # If we echo variable which contains multiple files without embedding it in double quotes all files in...
    #.. the variable will be listed in same line with spaces in between.

    # If we embedd them in double quotes each file will be listed in seperate line.

# echo "$FilesToDelete"

deleteFiles() {
    # '-z' is a test operator that checks if the string is null(i.e has a length of 0).
    # In this case it checks '$1' is an empty string, meaning no argument is provided.

    # Purpose:
        # To ensuse that the script is given a file name to work with. If no argument is given then
        #.. the script should not continue, as it wouldn't know which file to process.
    

    if [ -z $1 ]; then
        # This below line prints a usage message to the terminal.
        # '$0' represents the name of the script itself.If the script is called 'readfile.sh', then
        #.. '$0' would be 'readfile.sh'.

        # Purpose:
            # Provides the user with guidance on how to correctly run the script.
                # If they forget to pass the filename, this message reminds them of the correct usage.

        echo "usage: $0"
        # This command terminates the script and returns an exit status of 1 to the shell.
        exit 1
    fi

    # 'IFS': Stands for Internal Field Separator.It is a special shell variable that defines the characters used to separate words.
        # IFS=: Setting IFS= to an empty value temporarily disables word splitting.
        # This means that the read command will not split lines into multiple fields based on whitespace or other characters.
            # Purpose: Ensures that the entire line is read as a single unit, including any leading or trailing spaces.
            # ---------------------------------------------------------------------------------------------------
            # read: A built-in command used to read input from a file or standard input (stdin).
            # -r: Tells read to treat backslashes literally (i.e., not as escape characters). This prevents read from interpreting sequences like \n as newlines.
            # line: The variable line will hold the content of each line read from the file.
                # Purpose: This reads each line of the file into the line variable, handling spaces and backslashes correctly.
    while IFS= read -r files
    do
        echo "$files"
        # < "$filename": Redirects the contents of the file named filename to the while loop.
        # This means that the read command inside the loop reads from the file rather than from standard input.
    done < $1
}

deleteFiles "/home/shell/"







