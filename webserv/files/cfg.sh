#!/bin/bash

# Change the console resolution - DOES NOT WORK WITH GUEST ADDITIONS: USE SSH INSTEAD
# Option 1
# https://www.pendrivelinux.com/vga-boot-modes-to-set-screen-resolution/
# echo GRUB_CMDLINE_LINUX_DEFAULT="vga=795" >> /etc/default/grub
# grub2-mkconfig -o /boot/grub2/grub.cfg
# Option 2 (not tested)
# echo GRUB_GFXMODE=1280×720x24 >> /etc/default/grub
# echo GRUB_GFXPAYLOAD_LINUX=1280x720x24 >> /etc/default/grub

# Install RPM Fusion and update 
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -qy
dnf update -qy

# Install Fedora Cockpit management tools
dnf install cockpit -qy
systemctl enable --now cockpit.socket
firewall-cmd --add-service=cockpit --permanent

# Vbox guest additions installation needed for host disk sharing
dnf install gcc kernel-devel kernel-headers -qy 
mkdir --p /media/cdrom
mount -t auto /dev/cdrom /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run
# If this fails, check logs at /var/log/VboxGuestAdditions.log

# Install web apps
dnf install mariadb mariadb-server httpd mod_ssl php composer -qy
dnf install php-bcmath php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml -qy

# httpd configuration
cd /etc/httpd/conf.d
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/ampache.conf
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/wallabag.conf
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/owncloud.conf
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/phpinfo.conf

# PHP configuration
sed -i 's/post_max_size = 8M/post_max_size = 128M/' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/' /etc/php.ini

# Add firewall rules
# firewall-cmd --get-active-zones # Use this to check firewall zone if needed
firewall-cmd --permanent --zone=FedoraServer --add-port=80/tcp
firewall-cmd --permanent --zone=FedoraServer --add-port=443/tcp
systemctl restart firewalld.service

# Install FFMPEG (RPM Fusion) for Ampache transcoding
dnf install ffmpeg -qy

# Install Ampache
mkdir /var/www/html/ampache
cd /var/www/html/ampache
wget https://github.com/ampache/ampache/archive/master.tar.gz
tar -xvzf master.tar.gz --strip-components=1
rm master.tar.gz -f
dnf install git -qy # Required for Ampache composer install
composer install --prefer-source --no-interaction --quiet
chown -R apache:apache config
chcon -t httpd_sys_rw_content_t config -R # Changes the SELinux context to allow PHP to write to the folder
mkdir /media/ampache
mkdir /media/ampache/music
chown -R apache:apache /media/ampache
chcon -t httpd_sys_rw_content_t /media/ampache -R

# Install Wallabag
mkdir /var/www/html/wallabag
cd /var/www/html/wallabag
wget https://wllbg.org/latest-v2-package && tar xvf latest-v2-package --strip-components=1
rm latest-v2-package -f
chown -R apache:apache /var/www/html/wallabag
chcon -t httpd_sys_content_t /var/www/html/wallabag -R
chcon -t httpd_sys_rw_content_t /var/www/html/wallabag/data -R
chcon -t httpd_sys_rw_content_t /var/www/html/wallabag/var -R

# Install Owncloud
mkdir /var/www/html/owncloud
cd /var/www/html/owncloud
wget https://download.owncloud.com/download/community/setup-owncloud.php
cd /var/www/html/
chown -R apache:apache owncloud
chcon -t httpd_sys_rw_content_t  owncloud

# Install infopage
mkdir /var/www/html/phpinfo
cd /var/www/html/phpinfo
printf '<?php phpinfo(); ?>\n' > index.php

# Install certbot for SSL certificate creation
dnf install python3-certbot-apache -qy
cd cron.daily
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/renew_certs.sh

# Configure startup apps
systemctl enable mariadb
systemctl enable httpd.service

# Start apps
systemctl start mariadb
systemctl start httpd.service

# Automated mySQL config
dnf install expect -qy
expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Change the root password?\"
send \"y\r\"
expect \"New password:\"
send \"root\r\"
expect \"Re-enter new password:\"
send \"root\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
"
