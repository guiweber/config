# Headless qbitorrent server configuration
Instructions to configure a headless qbitorrent server on raspberry pi 4b with fedora 34+

## Prerequisites
- Install Fedora Server aarch64

## Run config bash file
- Connect to the server on port 22 with SSH
- Run the following commands as su:
 ```bash
 wget https://raw.githubusercontent.com/guiweber/config/master/kiki/cfg.sh -O cfg.sh && bash cfg.sh | tee cfg.log
```

## Finish configuration
- Add the following lines to the qbittorent config file, located at qbtuser/.config/qBittorrent/qBittorrent.conf,  then restart the service
 ```
[LegalNotice]
Accepted=true

[Preferences]
WebUI\Port=1999
WebUI\Address=*
WebUI\ServerDomains=*
WebUI\Enabled=true

 ```
 Then restart the service
 ```bash
 sudo systemctl restart qbittorrent
```
- If necessary use the following to see open ports
 ```bash
nmap localhost
```
