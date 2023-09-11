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

# Arguments
function usage() {
    echo -e "Usage: $0 [-h] \n"
}

function check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

# Checks passed arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--root) _ROOT=1; ;;
        -c|--command) _COMMAND=1 _COMMAND_DATA=$2; shift ;;
        -h|--help) usage ;; 
        # *) usage ;;
    esac
    shift
done

# Check if user is root
if [ ! -z ${_ROOT} ]; then
    check_root
fi

# Check passed command
if [ ${_COMMAND} -eq 1 ]; then
    if [ -z ${_COMMAND_DATA} ]; then
        echo "No command passed"
        exit 1
    fi
    echo "${_COMMAND_DATA}"
    exit 0
fi


# Script routines

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
