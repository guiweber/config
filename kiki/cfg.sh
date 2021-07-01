#!/bin/bash

# Create qbittorrent user and disable ssh login
adduser qbtuser
usermod -s /usr/sbin/nologin qbtuser

# Update and install software
dnf update -qy
dnf install qbittorrent-nox nmap -qy

