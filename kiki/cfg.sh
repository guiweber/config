#!/bin/bash

# Create qbittorrent user and disable ssh login
adduser qbtuser
usermod -s /usr/sbin/nologin qbtuser

# Update and install software
dnf update -qy
dnf install qbittorrent-nox nmap -qy

# creates the service
cd /etc/systemd/system/
wget https://raw.githubusercontent.com/guiweber/config/master/kiki/qbittorrent.service
systemctl daemon-reload
systemctl start qbittorrent
systemctl enable qbittorrent

# Port 80 cannot be used by normal users, bu we can redirect it to our port so that we dont have to enter the port in the address bar
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 2000
# To remove the redirect, the following line can be used
# iptables -t nat --line-numbers -n -L

# Add firewall rule for our port and port 80 (both will be useable)
firewall-cmd --add-port=2000/tcp --permanent
firewall-cmd --permanent --add-service=http
systemctl restart firewalld

# disable logging to disk
