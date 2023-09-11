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
        -u|--url) _URL=1 _URL_DATA=$2; ;;
        -t|--target) _TARGET=1 _TARGET_DATA=$2; ;;
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
if [[ "${_COMMAND}" -eq "1" ]]; then
    if [[ -z "${_COMMAND_DATA}" ]]; then
        echo "No command passed"
        exit 1
    fi
    # echo "${_COMMAND_DATA}"
fi

# Check passed URL
if [[ "${_URL}" -eq "1" ]]; then
    if [[ -z "${_URL_DATA}" ]]; then
        echo "No URL passed"
        exit 1
    fi
    ROOT_HINT_URL="${_URL_DATA}"
fi

# Check passed target
if [[ "${_TARGET}" -eq "1" ]]; then
    if [[ -z "${_TARGET_DATA}" ]]; then
        echo "No target passed"
        exit 1
    fi
    DOWNLOAD_TARGET="${_TARGET_DATA}"
fi

# Return concatenated string without last slash
function concat_string {
    local _STRING=$1
    local _STRING_LENGTH=${#_STRING}
    local _STRING_LENGTH_MINUS_ONE=$(( ${_STRING_LENGTH} - 1 ))
    local _STRING_WITHOUT_LAST_SLASH=${_STRING:0:${_STRING_LENGTH_MINUS_ONE}}
    echo "${_STRING_WITHOUT_LAST_SLASH}"
}

# Function delete word after previous slash
function delete_word_after_previous_slash {
    local _STRING=$1
    local _STRING_LENGTH=${#_STRING}
    local _STRING_LENGTH_MINUS_ONE=$(( ${_STRING_LENGTH} - 1 ))
    local _STRING_WITHOUT_LAST_SLASH=${_STRING:0:${_STRING_LENGTH_MINUS_ONE}}
    local _STRING_WITHOUT_LAST_WORD=${_STRING_WITHOUT_LAST_SLASH%/*}
    echo "${_STRING_WITHOUT_LAST_WORD}"
}
# Script routines

# Check if download folder exist
_TGT=$(delete_word_after_previous_slash "${DOWNLOAD_TARGET}")
if [ ! -d "${_TGT}" ]; then
  mkdir -p "${_TGT}"
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
    echo -e "Local target (${DOWNLOAD_TARGET}): ${Local} \nRemote: ${Remote}"
    if [ $Local -ne $Remote ]; then
        return 1
    else
        return 0
    fi
}

# Function run command
function run_command {
    if [[ "${_COMMAND}" -eq "1" ]]; then
        local _COMMAND_DATA=$1
        echo "${_COMMAND_DATA}" | sh
        # or can be used eval "${_COMMAND_DATA}"
    fi
}

# Check if file exist
if check_file_exist; then
  # Check if file size is equal to remote file size
  if check_file_size; then
    echo "File exist and size is equal to remote file size"
    # run_command "${_COMMAND_DATA}"
    exit 0
  else
    echo "File exist but size is not equal to remote file size. Downloading new file"
    # rm -f "${DOWNLOAD_TARGET}"
    # Download file
    wget -O "${DOWNLOAD_TARGET}" "${ROOT_HINT_URL}"
    # If command passed
    run_command "${_COMMAND_DATA}"
  fi
else
    echo "File not exist. Downloading new file"
    # Download file
    wget -O "${DOWNLOAD_TARGET}" "${ROOT_HINT_URL}"
    # If command passed
    run_command "${_COMMAND_DATA}"
fi
