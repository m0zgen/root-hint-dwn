#!/bin/bash
# This script is download DNS root hint file from internic.net
# Created by: Yevgeniy Goncharov, https://lab.sys-adm.in

# System variables
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Vars
# Download URL target path root.hints
URL="https://www.internic.net/domain/named.cache"
DESTINATION="/usr/share/dns/root.hints"

# Functions
# Function check if file size is equal to remote file size
function check_file_size {
    local Local=$(wc -c < "${DESTINATION}" | tr -d ' ')
    local Remote=$(curl -sI ${URL} | awk '/content-length/ {sub("\r",""); print $2}' | tr -d ' ')
    echo -e "Local target (${DESTINATION}): ${Local} \nRemote: ${Remote}"
    if [ $Local -ne $Remote ]; then
        return 1
    else
        return 0
    fi
}

# Processing
if [[ ! -d /usr/share/dns ]]; then
    mkdir -p /usr/share/dns
fi

if check_file_size; then
    echo "File exist and size is equal to remote file size"
    exit 0
else
    # Download file and save to target
    /usr/bin/curl -o "$DESTINATION" "$URL"

    # Check if curl successed curl
    if [ $? -eq 0 ]; then
        echo "root.hints sucessfully updated."
        if [[ $# -ne 1 ]]; then
            echo 'No any arguments passed to script' # >&2
            exit 1
        else
            echo "${1}" | sh
        fi
        # echo -e "\n; Downloaded at: $(date +%F-%T)" >> "$DESTINATION"
    else
        echo "Cant update root.hints some was wrong(."
    fi
fi
