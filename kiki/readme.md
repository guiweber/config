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
 Then restart the service and check that the webUI is accessible
 ```bash
 sudo systemctl restart qbittorrent
```

## Config VPN
As su, put the wireguard config in a file named wg0.conf in /etc/wireguard
Run 
```bash
systemctl enable wg-quick@wg0
systemctl daemon-reload
systemctl start wg-quick@wg0
sudo systemctl restart qbittorrent
```
Then open the webUI and bind the app to the wg0 interface


## Tips
- The IP whitelist range should be in CIDR notation, so 192.168.1.0/24 means the range 192.168.1.0 to 192.168.1.255
- If necessary use the following to route localhost to another linux computer (as suggested https://rawsec.ml/en/archlinux-install-qbittorrent-nox-setup-webui/) in order to test if the WebUI works on localhost
 ```bash
ssh username@server_ip -L 127.0.0.1:port_number:127.0.0.1:port_number -N
```

-  You can see open ports (doesn't mean they pass through the firewall though) with one of these commands. Port 80 will not be shown since there is no service listening actively on it (only redirecting)
 ```bash
nmap localhost
netstat -nltp
```

- The wireguard service may get confused is you use the non service "up" and "down" command while the service is running (e.g. disabling and re-enabling the service may not restore the tunnel)
-  You can see if a wireguard connection is active with 
 ```bash
wg show
```

- iptables it not used by Fedora anymore, firewall and redirects are managed by firewalld
- You can see firewalld rules
```bash
firewall-cmd --list-all
```

