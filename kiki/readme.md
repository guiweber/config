# Headless qbitorrent server configuration
Instructions to configure a headless qbitorrent server on raspberry pi 4b with fedora 36+

## Prerequisites
- Install Fedora Server aarch64
- Connect to the server on port 22 with SSH
- Run the following commands as su

## Expand system drive storage
The default SD partition may be small and may cause issues during updates. Use parted, with command resizepart, about the following once in parted:
```
print all
select /dev/mmcblk0
resizepart
quit
```
tutorial: https://linoxide.com/parted-commands-manage-disk-partition/
And then resize the Physical Volume (PV), logical volume and file system to match the partition using (if the partition is an LVM):
(Note! Check partition and volume names, which may vary)
 ```bash
pvresize /dev/mmcblk0p3
lvextend -l +100%FREE /dev/fedora_fedora/root
xfs_growfs /dev/fedora_fedora/root
```
ref: https://unix.stackexchange.com/questions/32145/how-to-expand-lvm2-partition-in-fedora-linux
ref2: https://www.rootusers.com/lvm-resize-how-to-increase-an-lvm-partition/

If not an LVM, or XFS system, look into using "resize2fs". See Tips section below for more useful commands

## Run config bash file
```bash
 wget https://raw.githubusercontent.com/guiweber/config/master/kiki/cfg.sh -O cfg.sh && bash cfg.sh | tee cfg.log
```

## Verify configuration
Check that the webUI is accessible on port 2000 and 80. If not, make sure that the qbittorrent config file at /home/qbtuser/.config/qBittorrent/qBittorrent.conf contains the lines from the config downloaded from github, and that the permissions are ok. If you make changes restart the service with ```systemctl restart qbittorrent```

## Connect external storage
The /mnt/usb_drive folder has already been created by the config script. Check if the permissions are ok before continuing with ```ls -l```. To automount a USB drive, display all drives with ```blkid``` when add the line below (replace UUID and file system type) to /etc/fstab
```UUID=F2A6B7D4A6B79795 /mnt/usb_drive    ntfs    context=system_u:object_r:samba_share_t:s0        0 0```
Note that the drive is open in the samba SE Linux context so that samba can read it. Maybe because of the ntfs filesystem or system location of the folder, it is not possible to change the SE Linux context in the traditional way (chcon). In case of issues (with different file systems), the SE Linux context can also be set at the file system level ("fscontext" instead of "context" in the /etc/fstab line).
Then run
```bash
systemctl daemon-reload
mount -a
```

Finally configure download location through the qbittorrent WebUI.

## Configure samba share
In Cockpit under "file-sharing", create a samba share at /mnt/usb_drive, allow user kiki_share and add a samba password to user kiki_share. Verify that you can access the share. Ex: From windows explorer type ```\\192.168.1.xxx\share_name```, then windows should ask you for the samba credentials.

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

## Config VPN port forward
TODO: To improve connectivity, we could have the VPN provider forward us incoming connections on the qbittorrent port (need to configure it with the provider) and map it in wireguard. Here are a few references on the subect:
- https://www.wjunction.com/threads/build-an-seedbox-dedicated-server-with-intergrated-vpn-for-bittorrent-yourself.256960/
- https://github.com/linuxserver/docker-wireguard/issues/58
- https://www.cyberciti.biz/faq/how-to-set-up-wireguard-firewall-rules-in-linux/

## Web console config
Connect to the web console and enable auto-updates
https://192.168.1.XXX:9090/updates


# Tips
- SE Linux can be put in permissive or enforcing mode: setenforce permissive/enforcing
- SE Linux folder/file labels can be seen with ```ls -ldZ```
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


- volume groups can be seen with:
 ```bash
vgs
vgdisplay
```
- logical volumes can be seen with:
 ```bash
vgs
vgdisplay -v
```
- all file systems (does not include volume groups) can be seen with:
 ```bash
df -h
```

