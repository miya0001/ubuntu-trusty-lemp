#!/usr/bin/env bash

set -ex

sudo apt-get update -y

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo apt-get install nodejs npm libcap2-bin git mysql-server curl php5-fpm php5-cli php5-curl php5-gd -y

sudo npm install n -g
sudo n latest
sudo ln -sf /usr/local/bin/node /usr/bin/node
sudo apt-get remove nodejs npm -y

sudo sh -c 'echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx-mainline-trusty.list'

curl http://nginx.org/packages/keys/nginx_signing.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install nginx

if [[ ! -e ~/.ssh/known_hosts ]]; then
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  chmod 600 ~/.ssh/known_hosts
fi

git clone https://github.com/letsencrypt/letsencrypt

sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get clean
