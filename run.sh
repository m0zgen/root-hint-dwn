#!/bin/bash
# This script is download DNS root hint file from internic.net
# Created by: Yevgeniy Goncharov, https://lab.sys-adm.in

# System variables
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Variables
ROOT_HINT_LOCAL_FILE="root.hints"
ROOT_HINT_URL="https://www.internic.net/domain/named.cache"
DOWNLOAD_FOLDER="${SCRIPT_PATH}/downloads"
DOWNLOAD_TARGET="${DOWNLOAD_FOLDER}/${ROOT_HINT_LOCAL_FILE}"
REMOTE_SIZE=$(curl -sI "${ROOT_HINT_URL}" | grep -i Content-Length | awk '{print $2}' | tr -d '\r')

# Check if download folder exist
if [ ! -d "${DOWNLOAD_FOLDER}" ]; then
  mkdir -p "${DOWNLOAD_FOLDER}"
fi

# Function check if file exist and return true if exist
function check_file_exist {
  if [ -f "${DOWNLOAD_TARGET}" ]; then
    return 0
  else
    return 1
  fi
}

# Function check if file size is equal to remote file size
function check_file_size {
    local Local=$(wc -c < "${DOWNLOAD_TARGET}" | tr -d ' ')
    local Remote=$(curl -sI ${ROOT_HINT_URL} | awk '/content-length/ {sub("\r",""); print $2}' | tr -d ' ')
    echo -e "Local: ${Local} \nRemote: ${Remote}"
    if [ $Local -ne $Remote ]; then
        return 1
    else
        return 0
    fi
}

# Check if file exist
if check_file_exist; then
  # Check if file size is equal to remote file size
  if check_file_size; then
    echo "File exist and size is equal to remote file size"
    exit 0
  else
    echo "File exist but size is not equal to remote file size. Downloading new file"
    # rm -f "${DOWNLOAD_TARGET}"
    # Download file
    wget -O "${DOWNLOAD_TARGET}" "${ROOT_HINT_URL}"
  fi
else
    echo "File not exist. Downloading new file"
    # Download file
    wget -O "${DOWNLOAD_TARGET}" "${ROOT_HINT_URL}"s
fi
