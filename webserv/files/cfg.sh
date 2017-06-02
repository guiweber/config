#!/bin/bash

# Install RPM Fusion and update 
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf update -y

# Vbox guest additions installation
dnf install gcc kernel-devel kernel-headers -y 
mkdir --p /media/cdrom
mount -t auto /dev/cdrom media/cdrom/
sh /media/cdrom/VBoxLinuxAdditions.run 

# Install web apps
dnf install mariadb mariadb-server httpd mod_ssl php composer -y
dnf install install php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml -y

# Install FFMPEG (RPM Fusion) for Ampache transcoding
dnf install ffmpeg -y

# Install certbot for SSL certificate creation
dnf install python-certbot-apache -y

# Install Ampache
mkdir /var/www/html/ampache
cd /var/www/html/ampache
wget https://github.com/ampache/ampache/archive/master.tar.gz
tar -xvzf master.tar.gz --strip-components=1
rm master.tar.gz -f
composer install --prefer-source --no-interaction

# Install Wallbag
mkdir /var/www/html/wallbag
cd /var/www/html/wallbag
wget https://github.com/wallabag/wallabag/archive/master.tar.gz
tar -xvzf master.tar.gz --strip-components=1
rm master.tar.gz -f
make install

# Install Owncloud
mkdir /var/www/html/owncloud
cd /var/www/html/owncloud
wget https://download.owncloud.org/community/owncloud-10.0.2.tar.bz2
tar -xvjf owncloud-10.0.2.tar.bz2 --strip-components=1
rm owncloud-10.0.2.tar.bz2 -f

# Configure startup apps
systemctl enable mariadb
systemctl enable httpd.service

# Start apps
systemctl start mariadb
systemctl start httpd.service

# Interactive mySQL config
mysql_secure_installation
