#!/usr/bin/env bash

readonly LLVM_VERSION=18
declare -ar LLVM_PACKAGES=(clang lldb lld)

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
        'install_llvm')
            error_msg="Could not download the OpenPGP \
                public key from ${1}\nTerminating..."
            exit_status=${2}
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
        echo -e ${error_msg} >&2
        tput sgr0 2> /dev/null      # Turn off all attributes
        exit ${exit_status}
    }
    echo -e ${error_msg} >&2
    exit ${exit_status}
}

check_binaries() {
    declare -a needed_binaries missing_binaries
    which which &> /dev/null || terminate "which"
    needed_binaries=(apt-get awk dpkg getopt gpg grep lsb_release sed wget)
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

readonly BASE_URL="https://apt.llvm.org"
readonly PPA_DIR="/etc/apt/sources.list.d/"
readonly GPG_DIR="/usr/share/keyrings/"
readonly GPG_PATH="/llvm-snapshot.gpg.key"
readonly LLVM_GPG_BASENAME="llvm.gpg"
readonly CODENAME=$(lsb_release -c | awk '{ print $NF }')
readonly LLVM_SOURCE_FILE="llvm.list"
readonly TYPE="deb"
readonly OPTIONS="[arch=amd64 signed-by=${GPG_DIR}${LLVM_GPG_BASENAME}]"
readonly URI="${BASE_URL}/${CODENAME}/"
readonly SUITE="llvm-toolchain-${CODENAME}-${LLVM_VERSION}"
readonly COMPONENTS="main"
readonly REPO="${TYPE} ${OPTIONS} ${URI} ${SUITE} ${COMPONENTS}"

print_apt_progress() {
    local progress_msg="\nRunning apt-get ${1}..."
    case "${1}" in
        'install')
            progress_msg+="\nInstalling the following packages: \
                ${install_pkgs[*]}"
        ;;
        'purge')
            progress_msg+="\nPurging the following packages: ${purge_pkgs[*]}"
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

print_source_list_progress() {
    local progress_msg
    case "${1}" in
        'key found')
            progress_msg="\nFound OpenPGP public key in ${GPG_DIR}"
        ;;
        'no key')
            progress_msg="\nAdded OpenPGP public key from \
                ${BASE_URL}${GPG_PATH} to ${GPG_DIR}"
        ;;
        'remove key')
            progress_msg="\nRemoved OpenPGP public key from ${GPG_DIR}"
        ;;
        'source found')
            progress_msg="\nFound entry in ${PPA_DIR}${LLVM_SOURCE_FILE}"
        ;;
        'no source')
            progress_msg="\nAdded entry to ${PPA_DIR}${LLVM_SOURCE_FILE}"
        ;;
        'remove source')
            progress_msg="\nRemoved ${PPA_DIR}${LLVM_SOURCE_FILE}"
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
    declare -a install_pkgs=()
    local wget_exit_status
    install_pkgs+=($(echo "${LLVM_PACKAGES[@]}" \
        | sed "s/\([a-z]\+\)/\1-${LLVM_VERSION}/g"))
    if [ -f "${GPG_DIR}${LLVM_GPG_BASENAME}" ]; then
        print_source_list_progress "key found"
    else
        {
            wget -qO ${GPG_DIR}${LLVM_GPG_BASENAME} ${BASE_URL}${GPG_PATH} &&
                cat ${GPG_DIR}${LLVM_GPG_BASENAME} \
                    | gpg --yes -o ${GPG_DIR}${LLVM_GPG_BASENAME} --dearmor &&
                chmod 0644 ${GPG_DIR}${LLVM_GPG_BASENAME} &&
                print_source_list_progress "no key"
        } || {
            wget_exit_status=$?
            rm ${GPG_DIR}${LLVM_GPG_BASENAME}
            terminate "${BASE_URL}${GPG_PATH}" "${wget_exit_status}"
        }
    fi
    grep -qsF "${REPO}" "${PPA_DIR}${LLVM_SOURCE_FILE}" &&
        print_source_list_progress "source found" ||
        {
            bash -c "echo ${REPO} >> ${PPA_DIR}${LLVM_SOURCE_FILE}"
            print_source_list_progress "no source"
        }
   print_apt_progress "update"; apt-get -q update
   print_apt_progress "install"; apt-get -yq install "${install_pkgs[@]}"
   print_apt_progress "autoremove"; apt-get -yq autoremove
}

purge_llvm() {
    declare -a purge_pkgs=()
    local regexp='-[[:digit:]]\\+[[:blank:]]\\+install$\\|'
    regexp=$(echo "${LLVM_PACKAGES[*]}" | sed "s/\([a-z]\+\)/^\1${regexp}/g" \
        | sed 's/ //g')
    purge_pkgs+=($(dpkg --get-selections | grep -o "${regexp}" \
        | awk '{ print $1 }' | paste -s -d ' '))
    [ -f "${PPA_DIR}${LLVM_SOURCE_FILE}" ] &&
        rm ${PPA_DIR}${LLVM_SOURCE_FILE} &&
        print_source_list_progress "remove source"
    [ -f "${GPG_DIR}${LLVM_GPG_BASENAME}" ] &&
        rm ${GPG_DIR}${LLVM_GPG_BASENAME} &&
        print_source_list_progress "remove key"
    [ ${#purge_pkgs[@]} -eq 0 ] || {
        print_apt_progress "purge"; apt-get -yq purge "${purge_pkgs[@]}"
        print_apt_progress "autoremove"; apt-get -yq autoremove
    }
}

main() {
    if [ ${INSTALL} ]; then
        [ -z ${PURGE} ] && install_llvm || { purge_llvm && install_llvm; }
    else
        purge_llvm; [ ${PURGE} ] || install_llvm
    fi
}

main
