#!/bin/bash

# Create qbittorrent user and disable ssh login
adduser qbtuser
usermod -s /usr/sbin/nologin qbtuser

# Update and install software
dnf update -qy
dnf install qbittorrent-nox nmap openvpn -qy

# creates the service
cd /etc/systemd/system/
wget https://raw.githubusercontent.com/guiweber/config/master/kiki/qbittorrent.service
systemctl daemon-reload
systemctl start qbittorrent
systemctl enable qbittorrent

# Add firewall rule for our port and port 80 (both will be useable)
firewall-cmd --add-port=2000/tcp --permanent
### Port 80 cannot be used by normal users (reserved for http), bu we can redirect it to our port so that we dont have to enter the port in the address bar
firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=2000
firewall-cmd --permanent --add-service=http
# If it doesn't work with only this, try this:
# firewall-cmd --permanent --zone=public --remove-port=80/tcp
systemctl restart firewalld

# Configure OpenVPN

# disable logging to disk
