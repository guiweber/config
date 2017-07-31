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
setsebool -P httpd_can_network_connect on # So that SELinux allows httpd to send mail through SMTP
cd /etc/httpd/conf.d
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/ampache.conf
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/wallabag.conf
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/nextcloud.conf
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/phpinfo.conf

# PHP configuration
sed -i 's/post_max_size = 8M/post_max_size = 10G/' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10G/' /etc/php.ini
sed -i 's/max_input_time = 60/max_input_time = 7200/' /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 7200/' /etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php.ini

# Add firewall rules
# firewall-cmd --get-active-zones # Use this to check firewall zone if needed
firewall-cmd --permanent --zone=FedoraServer --add-port=80/tcp
firewall-cmd --permanent --zone=FedoraServer --add-port=443/tcp
systemctl restart firewalld.service

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

# Configure Ampache media folder
## The following lines are for when using a VBox Shared Folder
cd /media
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/my_httpd_t.te
checkmodule -M -m -o my_httpd_t.mod my_httpd_t.te
semodule_package -o my_httpd_t.pp -m my_httpd_t.mod
semodule -i my_httpd_t.pp
systemctl restart httpd
rm my_httpd_t.* -f
usermod -aG vboxsf admin
usermod -aG vboxsf apache
## The following lines are for when using a local folder
#mkdir /media/ampache
#mkdir /media/ampache/music
#chown -R apache:apache /media/ampache
#chcon -t httpd_sys_rw_content_t /media/ampache -R

# Install Wallabag
mkdir /var/www/html/wallabag
cd /var/www/html/wallabag
wget https://wllbg.org/latest-v2-package && tar xvf latest-v2-package --strip-components=1
rm latest-v2-package -f
chown -R apache:apache /var/www/html/wallabag
chcon -t httpd_sys_content_t /var/www/html/wallabag -R
chcon -t httpd_sys_rw_content_t /var/www/html/wallabag/data -R
chcon -t httpd_sys_rw_content_t /var/www/html/wallabag/var -R

# Install Nextcloud
mkdir /var/www/html/nextcloud
cd /var/www/html/nextcloud
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/setup-nextcloud.php
chown -R apache:apache /var/www/html/nextcloud && chcon -t httpd_sys_rw_content_t  /var/www/html/nextcloud

# Install phpinfo page
mkdir /var/www/html/phpinfo
cd /var/www/html/phpinfo
printf '<?php phpinfo(); ?>\n' > index.php

# Enable and start services
systemctl enable --now mariadb
systemctl enable --now httpd.service

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

# Database configuration
## Nextcloud
mysql -u root -proot << "EOF"
CREATE DATABASE nextcloud;
GRANT ALL ON nextcloud.* TO nextcloud@localhost IDENTIFIED BY 'nextcloud';
EOF

# Install and run certbot for SSL certificate creation
## Note: For certbot to work, NO virtual host should be pre-configured to listen to port 443.
dnf install python3-certbot-apache -qy
cd /etc/cron.daily
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/renew_certs.sh
certbot --apache -n --agree-tos -d drive.stematics.net,music.stematics.net,phpinfo.stematics.net,wallabag.stematics.net

