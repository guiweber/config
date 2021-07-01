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
WebUI\Address=*
WebUI\AlternativeUIEnabled=false
WebUI\AuthSubnetWhitelist=192.168.1.0/24
WebUI\AuthSubnetWhitelistEnabled=true
WebUI\BanDuration=3600
WebUI\CSRFProtection=true
WebUI\ClickjackingProtection=true
WebUI\CustomHTTPHeaders=
WebUI\CustomHTTPHeadersEnabled=false
WebUI\Enabled=true
WebUI\HTTPS\CertificatePath=
WebUI\HTTPS\Enabled=false
WebUI\HTTPS\KeyPath=
WebUI\HostHeaderValidation=true
WebUI\LocalHostAuth=false
WebUI\MaxAuthenticationFailCount=5
WebUI\Password_PBKDF2="@ByteArray(On5iDRFbtl9fdDzxQ8A20g==:O9T1n9pKKHHhSFoIngteoL8oevZBynj7W4uDoCvBYmRMVPKw9fHm3yuyqfIRQ6XkPErK29ZGBhSDtiGYVxt2vA==)"
WebUI\Port=2000
WebUI\RootFolder=
WebUI\SecureCookie=true
WebUI\ServerDomains=*
WebUI\SessionTimeout=3600
WebUI\UseUPnP=false
WebUI\Username=kiki

 ```
 Then restart the service
 ```bash
 sudo systemctl restart qbittorrent
```

## Tips
- If necessary use the following to route localhost to another linux computer (as suggested https://rawsec.ml/en/archlinux-install-qbittorrent-nox-setup-webui/) in order to test if the WebUI works on localhost
 ```bash
ssh username@server_ip -L 127.0.0.1:8080:127.0.0.1:8080 -N
```

-  You can see open ports (doesn't mean they pass through the firewall though)
 ```bash
nmap localhost
```
