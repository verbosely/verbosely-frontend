#! /usr/bin/env bash

# Run this script on EC2 instances to install/upgrade nginx from sources.
# The tar.gz archive must be in ~/Downloads.

tar -zxf ~/Downloads/nginx-*tar.gz -C ~/Downloads;
rm ~/Downloads/nginx-*tar.gz;
sudo apt-get update;
sudo apt-get upgrade;

# Install dependencies if missing.
dpkg --get-selections | grep "[[:blank:]]install" \
    | grep "libpcre2-dev[:[:blank:]]" > /dev/null \
    || sudo apt-get install libpcre2-dev;
dpkg --get-selections | grep "[[:blank:]]install" \
    | grep "libpcre2-posix3[:[:blank:]]" > /dev/null \
    || sudo apt-get install libpcre2-posix3;
dpkg --get-selections | grep "[[:blank:]]install" \
    | grep "zlib1g-dev[:[:blank:]]" > /dev/null \
    || sudo apt-get install zlib1g-dev;
dpkg --get-selections | grep "[[:blank:]]install" \
    | grep "zlib1g[:[:blank:]]" > /dev/null \
    || sudo apt-get install zlib1g;
dpkg --get-selections | grep "[[:blank:]]install" \
    | grep "openssl[:[:blank:]]" > /dev/null \
    || sudo apt-get install openssl;
dpkg --get-selections | grep "[[:blank:]]install" \
    | grep "libssl-dev[:[:blank:]]" > /dev/null \
    || sudo apt-get install libssl-dev;
dpkg --get-selections | grep "[[:blank:]]install" \
    | grep "gcc[:[:blank:]]" > /dev/null \
    || sudo apt-get install gcc;

sudo apt-get autoremove;
sudo apt-get clean;
cd ~/Downloads/nginx-*;

./configure \
    --prefix=/usr/local/nginx \
    --with-http_ssl_module \
    --with-http_gzip_static_module \
    --with-http_v2_module \
    --with-stream;

make;
sudo make install;
cd ..;
rm -r nginx-*;

# Create symbolic link to nginx binary if missing.
[ -L /usr/local/bin/nginx ] \
    || sudo ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx;

# Create nginx user if missing.
awk -F : '{print $1}' /etc/passwd | grep "nginx" > /dev/null \
    || sudo useradd -r nginx;

sudo chown -R nginx /usr/local/nginx/logs;
sudo chmod -R 0744 /usr/local/nginx/logs;
