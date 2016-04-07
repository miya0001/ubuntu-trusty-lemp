#!/usr/bin/env bash

set -ex

sudo apt-get update -y

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo apt-get install nodejs npm libcap2-bin git mysql-server curl apache2 jq -y

# Installs Node latest
sudo npm install n -g
sudo n latest
sudo ln -sf /usr/local/bin/node /usr/bin/node
sudo apt-get remove nodejs npm -y

# Installs Nginx from mainline
sudo sh -c 'echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx-mainline-trusty.list'
curl http://nginx.org/packages/keys/nginx_signing.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install nginx -y

# Installs ruby
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:brightbox/ruby-ng -y
sudo apt-get update -y
sudo apt-get install ruby2.3 -y
sudo apt-get install ruby-switch -y
sudo ruby-switch --set ruby2.3
sudo gem install bundle

# Installs php7
sudo apt-get install -y language-pack-en-base -y
sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php -y
sudo apt-get update
sudo apt-get install php7.0 libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-gd php7.0-json php7.0-mbstring php7.0-xml php7.0-zip  -y

sudo sh -c "cat <<EOS > /etc/php/7.0/apache2/conf.d/20-upload.ini
upload_max_filesize=20M
post_max_size=20M
EOS"

# Installs composer
php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === '7228c001f88bee97506740ef0888240bd8a760b046ee16db8f4095c0d8d525f2367663f22a46b48d072c816e7fe19959') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

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
sudo service apache2 restart

# nginx
sudo openssl dhparam 2048 -out /etc/ssl/private/dhparam.pem

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
    proxy_cache_valid  200 301 302 303 304 0;
    proxy_cache_valid any 0;
    proxy_pass http://localhost:8080;
  }
}
EOS'

# wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
/usr/local/bin/wp package install miya0001/wp-cli-vhosts:@stable

# change owner
sudo chown -R $(whoami):$(whoami) /var/www
sudo chown -R $(whoami):$(whoami) /var/cache/nginx
sudo chown -R $(whoami):$(whoami) /var/lib/php/sessions

sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get clean

sudo service apache2 restart
sudo service nginx restart
sudo service mysql restart

sudo service ssh reload
