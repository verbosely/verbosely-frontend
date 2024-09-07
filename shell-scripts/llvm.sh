LLVM_VERSION=18
BASE_URL="http://apt.llvm.org"
CODENAME=$(lsb_release -c | awk '{ print $NF }')
CURRENT_VERSION=$(dpkg --get-selections | grep "[[:blank:]]install$" \
    | grep ^clang-[[:digit:]] | awk '{ print $1 }' \
    | awk 'BEGIN { FS = "[^0-9]" }; { print $NF }')
 
packages() {
    echo "clang-$1 lldb-$1 lld-$1 clangd-$1"
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
