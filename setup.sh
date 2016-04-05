#!/usr/bin/env bash

set -ex

sudo apt-get update -y

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo apt-get install nodejs npm libcap2-bin git mysql-server curl apache2 libapache2-mod-php5 php5-cli php5-curl php5-gd jq -y

# Installs Node latest
sudo npm install n -g
sudo n latest
sudo ln -sf /usr/local/bin/node /usr/bin/node
sudo apt-get remove nodejs npm -y

# Installs Nginx from mainline
sudo sh -c 'echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx-mainline-trusty.list'
curl http://nginx.org/packages/keys/nginx_signing.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install nginx

# Installs GitHub's key
if [[ ! -e ~/.ssh/known_hosts ]]; then
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  chmod 600 ~/.ssh/known_hosts
fi

# Installs let's encrypt
if [[ ! -d ~/letsencrypt ]]; then
  git clone https://github.com/letsencrypt/letsencrypt
fi

# ssh
sudo sh -c "sed -i -e 's/^PermitRootLogin without-password/PermitRootLogin no/' /etc/ssh/sshd_config"
sudo sh -c "sed -i -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"

# apache2
sudo sh -c "sed -i -e 's/www-data/$(whoami)/' /etc/apache2/envvars"
sudo sh -c "echo 'Listen 8080' > /etc/apache2/ports.conf"
sudo sh -c "echo 'AddDefaultCharset UTF-8' > /etc/apache2/conf-available/charset.conf"
sudo sh -c "sed -i -e 's/^ServerTokens OS/ServerTokens Minimal/' /etc/apache2/conf-available/security.conf"
sudo sh -c "sed -i -e 's/^ServerSignature On/ServerSignature Off/' /etc/apache2/conf-available/security.conf"
sudo sh -c "sed -i -e 's/Options Indexes/Options/' /etc/apache2/apache2.conf"
sudo sh -c "sed -i -e 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf"
sudo sh -c "echo '' > /var/www/html/index.html"
sudo sh -c "echo '<?php phpinfo(); ?>' > /var/www/html/phpinfo.php"
sudo sh -c "echo 'ServerName localhost:8080' > /etc/apache2/conf-available/servername.conf"
sudo a2enconf servername
sudo a2dismod ssl

# php
sudo sh -c "cat <<EOS > /etc/php5/apache2/conf.d/20-upload.ini
upload_max_filesize=20M
post_max_size=20M
EOS"

# nginx
sudo openssl dhparam 2048 -out /etc/nginx/ssl/dhparam.pem

sudo sh -c "cat << EOS > /etc/nginx/nginx.conf
user  $(whoami) $(whoami);
worker_processes  2;
worker_rlimit_nofile 10240;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
  worker_connections  8192;
  multi_accept on;
  use epoll;
}

http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;
  access_log  off;
  sendfile        on;
  tcp_nopush      on;
  keepalive_timeout  10;
  gzip  on;
  include /etc/nginx/conf.d/*.conf;
}
EOS"

sudo sh -c 'cat << EOS > /etc/nginx/conf.d/default.conf
proxy_cache_path  /var/cache/nginx/default levels=1:2 keys_zone=default:4m max_size=50m inactive=30d;

server {
  listen 80 default_server;
  server_name _;
  client_max_body_size 10M;

  location / {
    proxy_set_header Host \$host;
    proxy_set_header Remote-Addr \$remote_addr;
    proxy_cache default;
    proxy_cache_key "\$scheme://\$host\$request_uri";
    proxy_cache_valid  200 301 302 303 304 1d;
    proxy_cache_valid any 1m;
    proxy_pass http://localhost:8080;
  }
}
EOS'

# wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# change owner
sudo chown -R $(whoami):$(whoami) /var/www
sudo chown -R $(whoami):$(whoami) /var/cache/nginx
sudo chown -R $(whoami):$(whoami) /var/lib/php5

sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get clean

sudo service apache2 restart
sudo service nginx restart
sudo service mysql restart

sudo service ssh reload
