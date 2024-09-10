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
    needed_binaries=(lsb_release awk dpkg grep
                     wget add-apt-repository tee apt-get)
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

parse_args $*
check_root_user
check_binaries

BASE_URL="http://apt.llvm.org"
CODENAME=$(lsb_release -c | awk '{ print $NF }')
CURRENT_VERSION=$(dpkg --get-selections | grep "[[:blank:]]install$" \
    | grep ^clang-[[:digit:]] | awk '{ print $1 }' \
    | awk 'BEGIN { FS = "[^0-9]" }; { print $NF }')

packages() {
    echo "clang-$1 lldb-$1 lld-$1"
}

repo() {
    echo "deb ${BASE_URL}/${CODENAME}/ llvm-toolchain-${CODENAME}-$1 main"
}

install_llvm() {
    PKGS=$(packages ${LLVM_VERSION})
    REPO=$(repo ${LLVM_VERSION})
    [ ! -f /etc/apt/trusted.gpg.d/apt.llvm.org.asc ] \
        && wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key \
            | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
    add-apt-repository -L | grep "${REPO}" 1> /dev/null \
        || add-apt-repository -y "${REPO}"
    apt-get update
    apt-get -y install ${PKGS}
}

uninstall_llvm() {
    PKGS=$(packages ${CURRENT_VERSION})
    REPO=$(repo ${CURRENT_VERSION})
    [ ${CURRENT_VERSION} ] && [ ${CURRENT_VERSION} != ${LLVM_VERSION} ] \
        && apt-get -y purge ${PKGS} && apt-get -y autoremove \
        && add-apt-repository -L | grep "${REPO}" 1> /dev/null \
        && add-apt-repository -r -y "${REPO}"
}

uninstall_llvm
install_llvm
