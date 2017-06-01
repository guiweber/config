#!/bin/bash

dnf update -y

# Vbox guest additions installation
dnf install gcc kernel-devel kernel-headers -y 
mkdir --p /media/cdrom
mount -t auto /dev/cdrom media/cdrom/
sh /media/cdrom/VBoxLinuxAdditions.run 

dnf install docker -y
dnf install mariadb -y

systemctl start docker
systemctl enable docker

docker pull ampache/ampache
docker pull mariadb

docker run --name maria -e MYSQL_ROOT_PASSWORD=my-pw -e MYSQL_ROOT_HOST=172.17.0.1 -d -p 3306:3306 mariadb
# The root host IP is set to the default Docker gateway

mkdir /home/media
mkdir /home/media/music
docker run --name ampache --link maria:maria -d -v /home/media:/media:z -p 80:80 ampache/ampache
# Note that the "z" suffix on the share is to allow access through SELinux (docker wil label the files properly for sharing with container)

mysql -u root -p my-pw -h 172.17.0.2 --execute="CREATE USER 'admin'@'%' IDENTIFIED BY 'my-pw'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;"
