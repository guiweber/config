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
dnf install mariadb httpd mod_ssl php composer -y
dnf install install php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml -y

# Install FFMPEG (RPM Fusion) for Ampache transcoding
dnf install ffmpeg -y

# Install certbot for SSL certificate creation
dnf install python-certbot-apache -y

# Install Ampache
cd /var/tmp
wget https://github.com/ampache/ampache/archive/master.tar.gz
tar -xvzf master.tar.gz
mv master /var/www/html/ampache
cd /var/www/html/ampache
composer install --prefer-source --no-interaction

# Install Wallbag
cd /var/tmp
wget https://github.com/wallabag/wallabag/archive/master.tar.gz
tar -xvzf master.tar.gz
mv master /var/www/html/wallbag
cd /var/www/html/wallbag
make install

# Install Owncloud
cd /var/tmp
wget https://download.owncloud.org/community/owncloud-10.0.2.tar.bz2
tar -xvzf owncloud-10.0.2.tar.bz2
mv owncloud-10.0.2 /var/www/html/owncloud

# Configure startup apps
systemctl enable mariadb
systemctl enable httpd.service

# Start apps
systemctl start mariadb
systemctl start httpd.service


# Interactive mySQL config
mysql_secure_installation
