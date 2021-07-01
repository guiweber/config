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


# disable logging to disk
