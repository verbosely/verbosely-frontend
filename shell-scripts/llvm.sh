#!/usr/bin/env bash

LLVM_VERSION=18

usage() {
    cat <<- USAGE
Usage: ./$(basename "${0}") [OPTION]
    
Summary:
    Install the LLVM tools needed to build Python with
    --enable-optimizations and --with-lto configure options. The major
    version to install is specified in the shell parameter
    LLVM_VERSION (=${LLVM_VERSION}) at the top of the script. If a
    different major version is already installed on the system, then
    that version will be purged before the version that LLVM_VERSION
    expands to is installed.

    The following LLVM tools will be installed:
    clang: an "LLVM native" C/C++/Objective-C compiler
    lldb: a C/C++/Objective-C debugger
    lld: the LLVM linker

    Refer here for more info: https://llvm.org

Options:
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
    [ ${#missing_binaries[@]} -gt 0 ] \
        && echo You must install the following tools to run this script: \
            ${missing_binaries[@]} >&2 \
        && exit 1
}

parse_args() {
    TEMP=$(getopt -o 'h' --long 'help' -n $(basename "${0}") -- "$@")
    getopt_exit_status=$?
    [ ${getopt_exit_status} -ne 0 ] \
        && echo 'Terminating...' >&2 \
        && exit ${getopt_exit_status}
    eval set -- "$TEMP"
    unset TEMP
    while true; do
        case "$1" in
            '-h'|'--help')
                usage
                exit 0
            ;;
            '--')
                shift
                break
            ;;
        esac
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
CURRENT_VERSION=$(dpkg --get-selections | grep "[[:blank:]]install$" \
    | grep ^clang-[[:digit:]] | awk '{ print $1 }' \
    | awk 'BEGIN { FS = "[^0-9]" }; { print $NF }')
CURRENT_LLVM_SOURCE_FILE="llvm-${CURRENT_VERSION}.list"
LLVM_SOURCE_FILE="llvm-${LLVM_VERSION}.list"

packages() {
    echo "clang-$1 lldb-$1 lld-$1"
}

repo() {
    echo deb [arch=amd64 signed-by=${GPG_DIR}/${LLVM_GPG_BASENAME}] \
        ${BASE_URL}/${CODENAME}/ llvm-toolchain-${CODENAME}-$1 main
}

install_llvm() {
    PKGS=$(packages ${LLVM_VERSION})
    REPO=$(repo ${LLVM_VERSION})
    [ -f ${GPG_DIR}/${LLVM_GPG_BASENAME} ] \
        || wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key \
            | gpg -o ${GPG_DIR}/${LLVM_GPG_BASENAME} --dearmor \
        && chmod 0644 ${GPG_DIR}/${LLVM_GPG_BASENAME}

    [ -f ${PPA_DIR}/${LLVM_SOURCE_FILE} ] \
        || bash -c "echo ${REPO} > ${PPA_DIR}/${LLVM_SOURCE_FILE}"
    apt-get update
    apt-get -y install ${PKGS}
    apt-get -y autoremove
}

uninstall_llvm() {
    PKGS=$(packages ${CURRENT_VERSION})
    REPO=$(repo ${CURRENT_VERSION})
    [ ${CURRENT_VERSION} ] && [ ${CURRENT_VERSION} != ${LLVM_VERSION} ] \
        && apt-get -y purge ${PKGS} \
        && [ -f ${PPA_DIR}/${CURRENT_LLVM_SOURCE_FILE} ] \
        && rm ${PPA_DIR}/${CURRENT_LLVM_SOURCE_FILE}
}

uninstall_llvm
install_llvm
