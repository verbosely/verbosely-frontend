#! /usr/bin/env bash

# Run this script on EC2 instances to install/upgrade nginx from sources.
# The tar.gz archive must be in ~/Downloads.

tar -zxf ~/Downloads/nginx-*tar.gz -C ~/Downloads;
rm ~/Downloads/nginx-*tar.gz;
sudo apt-get update;
sudo apt-get upgrade;
sudo apt-get autoremove;
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

[ -L /usr/local/bin/nginx ] \
    || sudo ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx;

awk -F : '{print $1}' /etc/passwd | grep 'nginx' > /dev/null \
    || sudo useradd -r nginx;

sudo chown -R nginx /usr/local/nginx/logs;
sudo chmod -R 0744 /usr/local/nginx/logs;
