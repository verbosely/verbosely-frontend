#!/usr/bin/env bash

LLVM_VERSION=18

usage() {
    cat <<- USAGE
Usage: ./$(basename "${0}") [OPTION...]
    
Summary:
    Purge and/or install LLVM packages for Debian-based systems.

    The following LLVM tools will be purged and/or installed:
    clang: an "LLVM native" C/C++/Objective-C compiler
    lldb: a C/C++/Objective-C debugger
    lld: the LLVM linker

    Refer here for more info: https://llvm.org

Package management options:
    -p | --purge    purge all existing LLVM packages
    -i | --install  install LLVM packages for the version specified in
                    the shell parameter LLVM_VERSION (=${LLVM_VERSION})
                    located at the top of the script
    -r | --replace  purge all existing LLVM packages, then install the
                    version specified in the shell parameter
                    LLVM_VERSION (=${LLVM_VERSION}); equivalent to
                    running "./$(basename "${0}") -pi" (default)

Other options:
    -h | --help     display this help text, and exit
USAGE
}

check_root_user() {
    [ ${EUID} -ne 0 ] && echo "This script must be run as root!" >&2 && exit 1
}

check_binaries() {
    needed_binaries=(lsb_release awk dpkg grep gpg getopt wget apt-get)
    missing_binaries=()
    for binary in "${needed_binaries[@]}"; do
        which ${binary} &> /dev/null || missing_binaries+=($binary)
    done
    [ ${#missing_binaries[@]} -gt 0 ] &&
        echo You must install the following tools to run this script: \
            ${missing_binaries[@]} >&2 &&
        exit 1
}

check_conflicting_args() {
    if [ ${REPLACE} ]; then
        if [ ${INSTALL} ]; then
            CONFLICTING_OPTS_MSG="Illegal combination of options: \
                -r|--replace, -i|--install"
        elif [ ${PURGE} ]; then
            CONFLICTING_OPTS_MSG="Illegal combination of options: \
                -r|--replace, -p|--purge"
        fi
    fi
    [ "${CONFLICTING_OPTS_MSG}" ] && echo ${CONFLICTING_OPTS_MSG} >&2 && exit 1
}

parse_args() {
    temp=$(getopt -o 'hipr' -l 'help,install,purge,replace' \
        -n $(basename "${0}") -- "$@")
    getopt_exit_status=$?
    [ ${getopt_exit_status} -ne 0 ] && echo 'Terminating...' >&2 &&
        exit ${getopt_exit_status}
    eval set -- "${temp}"
    unset temp
    while true; do
        case "$1" in
            '-h'|'--help')
                usage
                exit 0
            ;;
            '-i'|'--install')
                [ -z ${INSTALL} ] && INSTALL="yes"
                shift
            ;;
            '-p'|'--purge')
                [ -z ${PURGE} ] && PURGE="yes"
                shift
            ;;
            '-r'|'--replace')
                [ -z ${REPLACE} ] && REPLACE="yes"
                shift
            ;;
            '--')
                shift
                break
            ;;
        esac
        check_conflicting_args
    done
    [ $# -ne 0 ] && usage >&2 && exit 1
}

check_binaries
parse_args $*
check_root_user

BASE_URL="http://apt.llvm.org"
PPA_DIR="/etc/apt/sources.list.d"
GPG_DIR="/usr/share/keyrings"
LLVM_GPG_BASENAME="apt.llvm.org.gpg"
CODENAME=$(lsb_release -c | awk '{ print $NF }')
REGEX_PATTERN="clang-([[:digit:]]+)"
[[ $(dpkg --get-selections | grep "^clang-[[:digit:]].*[[:blank:]]install$") \
    =~ ${REGEX_PATTERN} ]]
CURRENT_VERSION=${BASH_REMATCH[1]}
CURRENT_LLVM_SOURCE_FILE="llvm-${CURRENT_VERSION}.list"
LLVM_SOURCE_FILE="llvm.list"
TYPE="deb"
OPTIONS="[arch=amd64 signed-by=${GPG_DIR}/${LLVM_GPG_BASENAME}]"
URI="${BASE_URL}/${CODENAME}/"
SUITE="llvm-toolchain-${CODENAME}-${LLVM_VERSION}"
COMPONENTS="main"
REPO="${TYPE} ${OPTIONS} ${URI} ${SUITE} ${COMPONENTS}"

packages() {
    pkgs="clang-$1 lldb-$1 lld-$1"
}

install_llvm() {
    packages ${LLVM_VERSION}
    [ -f ${GPG_DIR}/${LLVM_GPG_BASENAME} ] || {
        wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key \
            | gpg -o ${GPG_DIR}/${LLVM_GPG_BASENAME} --dearmor &&
        chmod 0644 ${GPG_DIR}/${LLVM_GPG_BASENAME}
    }

    grep -qsF "${REPO}" "${PPA_DIR}/${LLVM_SOURCE_FILE}" ||
        bash -c "echo ${REPO} >> ${PPA_DIR}/${LLVM_SOURCE_FILE}"
    echo -e "\nRunning apt-get update..."
    apt-get -q update
    echo -e "\nRunning apt-get install..."
    apt-get -y install ${pkgs}
    echo -e "\nRunning apt-get autoremove..."
    apt-get -y autoremove
}

uninstall_llvm() {
    packages ${CURRENT_VERSION}
    [ ${CURRENT_VERSION} ] && [ ${CURRENT_VERSION} != ${LLVM_VERSION} ] &&
        apt-get -y purge ${pkgs} &&
        [ -f ${PPA_DIR}/${CURRENT_LLVM_SOURCE_FILE} ] &&
        rm ${PPA_DIR}/${CURRENT_LLVM_SOURCE_FILE}
}

if [ ${INSTALL} ]; then
    if [ -z ${PURGE} ]; then
        install_llvm
    else
        uninstall_llvm
        install_llvm
    fi
else
    if [ ${PURGE} ]; then
        uninstall_llvm
    else
        uninstall_llvm
        install_llvm
    fi
fi
