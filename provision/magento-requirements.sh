#!/bin/bash

set -e
set -x

echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections

sudo apt-get install -y apache2 php7.0 php7.0-common \
    php7.0-gd php7.0-mysql php7.0-mcrypt \
    php7.0-curl php7.0-intl php7.0-xsl \
    php7.0-mbstring php7.0-zip php7.0-bcmath \
    php7.0-iconv php-xdebug libapache2-mod-php7.0 \
    mysql-server \
    git \
    zip unzip bzip2 \
    bash-completion

sudo a2enmod rewrite
sudo a2enmod ssl

# Specific configuration per PHP cli
PHP_CONFIG_CLI=$(cat <<EOF
memory_limit=2G
error_reporting=E_ALL
max_execution_time=18000
max_input_vars=1000000
EOF
)
echo "$PHP_CONFIG_CLI" | sudo tee /etc/php/7.0/cli/conf.d/php_cli_provision.ini

# Specific configuration per PHP as Apache module
PHP_CONFIG_APACHE=$(cat <<EOF
memory_limit=2G
error_reporting=E_ALL
max_execution_time=18000
post_max_size=200M
upload_max_filesize=200M
EOF
)
echo "$PHP_CONFIG_APACHE" | sudo tee /etc/php/7.0/apache2/conf.d/php_provision.ini

# Enabling Xdebug remote debugging
XDEBUG_CONFIG=$(cat <<EOF
zend_extension=xdebug.so
xdebug.remote_enable=on
xdebug.remote_connect_back=on
xdebug.html_errors=1
xdebug.extended_info=1
EOF
)
echo "$XDEBUG_CONFIG" | sudo tee /etc/php/7.0/mods-available/xdebug.ini