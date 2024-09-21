#!/usr/bin/env bash

readonly LLVM_VERSION=18

usage() {
    cat <<- USAGE
Usage: ./$(basename "${0}") [OPTION...]
    
Summary:
    Purge and/or install LLVM packages for Debian-based Linux.

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

terminate() {
    local error_msg
    declare -i exit_status=1
    case "${FUNCNAME[1]}" in
        'check_binaries')
            error_msg="You must install the following \
                tools to run this script: ${1}"
        ;;
        'check_conflicting_args')
            error_msg="Illegal combination of options: ${1}"
        ;;
        'check_root_user')
            error_msg="This script must be run as root!"
        ;;
        'parse_args')
            error_msg="Terminating..."
            exit_status=${1}
        ;;
        *)
            error_msg="Something went wrong. Terminating..."
        ;;
    esac
    tput -V &> /dev/null && {
        tput sgr0 2> /dev/null      # Turn off all attributes
        tput rev 2> /dev/null       # Turn on reverse video mode
        tput bold 2> /dev/null      # Turn on bold mode
        tput setaf 1 2> /dev/null   # Set foreground color to red
        echo ${error_msg} >&2
        tput sgr0 2> /dev/null      # Turn off all attributes
        exit ${exit_status}
    }
    echo ${error_msg} >&2
    exit ${exit_status}
}

check_binaries() {
    declare -a needed_binaries missing_binaries
    which which &> /dev/null || terminate "which"
    needed_binaries=(apt-get awk dpkg getopt gpg grep lsb_release wget)
    missing_binaries=()
    for binary in "${needed_binaries[@]}"; do
        which ${binary} &> /dev/null || missing_binaries+=($binary)
    done
    [ ${#missing_binaries[@]} -gt 0 ] && terminate "${missing_binaries[*]}"
}

check_conflicting_args() {
    local conflicting_opts
    if [ ${REPLACE} ]; then {
        [ ${INSTALL} ] && conflicting_opts="-r|--replace, -i|--install"
    } || {
        [ ${PURGE} ] && conflicting_opts="-r|--replace, -p|--purge"
    }
    fi
    [ "${conflicting_opts}" ] && terminate "${conflicting_opts}"
}

parse_args() {
    local temp
    declare -i getopt_exit_status
    temp=$(getopt -o 'hipr' -l 'help,install,purge,replace' \
        -n $(basename "${0}") -- "$@")
    getopt_exit_status=$?
    [ ${getopt_exit_status} -ne 0 ] && terminate ${getopt_exit_status}
    eval set -- "${temp}"
    unset temp
    while true; do
        case "$1" in
            '-h'|'--help')
                usage
                exit 0
            ;;
            '-i'|'--install')
                [ -z ${INSTALL} ] && readonly INSTALL="yes"
                shift
            ;;
            '-p'|'--purge')
                [ -z ${PURGE} ] && readonly PURGE="yes"
                shift
            ;;
            '-r'|'--replace')
                [ -z ${REPLACE} ] && readonly REPLACE="yes"
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

check_root_user() {
    [ ${EUID} -ne 0 ] && terminate
}

check_binaries; parse_args $*; check_root_user

readonly BASE_URL="http://apt.llvm.org"
readonly PPA_DIR="/etc/apt/sources.list.d/"
readonly GPG_DIR="/usr/share/keyrings/"
readonly LLVM_GPG_BASENAME="apt.llvm.org.gpg"
readonly CODENAME=$(lsb_release -c | awk '{ print $NF }')
readonly REGEX_PATTERN="clang-([[:digit:]]+)"
[[ $(dpkg --get-selections | grep "^clang-[[:digit:]].*[[:blank:]]install$") \
    =~ ${REGEX_PATTERN} ]]
readonly CURRENT_VERSION=${BASH_REMATCH[1]}
readonly CURRENT_LLVM_SOURCE_FILE="llvm-${CURRENT_VERSION}.list"
readonly LLVM_SOURCE_FILE="llvm.list"
readonly TYPE="deb"
readonly OPTIONS="[arch=amd64 signed-by=${GPG_DIR}${LLVM_GPG_BASENAME}]"
readonly URI="${BASE_URL}/${CODENAME}/"
readonly SUITE="llvm-toolchain-${CODENAME}-${LLVM_VERSION}"
readonly COMPONENTS="main"
readonly REPO="${TYPE} ${OPTIONS} ${URI} ${SUITE} ${COMPONENTS}"

packages() {
    pkgs="clang-$1 lldb-$1 lld-$1"
}

print_apt_progress() {
    local progress_msg="\nRunning apt-get ${1}..."
    tput -V &> /dev/null && {
        tput sgr0 2> /dev/null      # Turn off all attributes
        tput bold 2> /dev/null      # Turn on bold mode
        tput setaf 6 2> /dev/null   # Set foreground color to cyan
        echo -e ${progress_msg}
        tput sgr0 2> /dev/null      # Turn off all attributes
    } || echo -e ${progress_msg}
}

print_source_list_progress() {
    local progress_msg
    case "${1}" in
        'key')
            progress_msg="\nAdding OpenPGP public key to ${2}"
        ;;
        'sources')
            progress_msg="\nAdding source to ${2}"
        ;;
    esac
    tput -V &> /dev/null && {
        tput sgr0 2> /dev/null      # Turn off all attributes
        tput bold 2> /dev/null      # Turn on bold mode
        tput setaf 6 2> /dev/null   # Set foreground color to cyan
        echo -e ${progress_msg}
        tput sgr0 2> /dev/null      # Turn off all attributes
    } || echo -e ${progress_msg}
}

install_llvm() {
    local pkgs
    packages ${LLVM_VERSION}
    [ -f "${GPG_DIR}${LLVM_GPG_BASENAME}" ] || {
        print_source_list_progress "key" "${GPG_DIR}"
        wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key \
            | gpg -o ${GPG_DIR}${LLVM_GPG_BASENAME} --dearmor &&
        chmod 0644 ${GPG_DIR}${LLVM_GPG_BASENAME}
    }
    grep -qsF "${REPO}" "${PPA_DIR}${LLVM_SOURCE_FILE}" || {
        print_source_list_progress "sources" "${PPA_DIR}${LLVM_SOURCE_FILE}"
        bash -c "echo ${REPO} >> ${PPA_DIR}${LLVM_SOURCE_FILE}"
    }
    print_apt_progress "update"; apt-get -q update
    print_apt_progress "install"; apt-get -y install ${pkgs}
    print_apt_progress "autoremove"; apt-get -y autoremove
}

uninstall_llvm() {
    local pkgs
    packages ${CURRENT_VERSION}
    [ ${CURRENT_VERSION} ] && [ ${CURRENT_VERSION} != ${LLVM_VERSION} ] &&
        apt-get -y purge ${pkgs} &&
        [ -f "${PPA_DIR}${CURRENT_LLVM_SOURCE_FILE}" ] &&
        rm ${PPA_DIR}${CURRENT_LLVM_SOURCE_FILE}
}

main() {
    if [ ${INSTALL} ]; then
        [ -z ${PURGE} ] && install_llvm || { uninstall_llvm && install_llvm; }
    else
        [ ${PURGE} ] && uninstall_llvm || { uninstall_llvm && install_llvm; }
    fi
}

main
