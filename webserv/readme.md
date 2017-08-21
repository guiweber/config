# Ampache server configuration
These are instructions to configure Fedora webserver running Ampache, Owncloud and Wallabag on VirtualBox. At the time of writing, Fedora 26 is used.

## Prerequisites
- Install Fedora Server
- Configure port forwarding (22, 80, 443) in your internet router and through VirtualBox.

## Run config bash file
- Make sure the guest additions CD is inserted into virtual box
- Connect to the server on port 22 with SSH
- Run the following commands as su:
 ```bash
 wget https://goo.gl/LCs85o -O cfg.sh && bash cfg.sh | tee cfg.log
```

## Configure Apache
If you want to enable HTTP2, you need to enable php-fpm and MPM Event as well. The reason for these two last changes is that HTTP2 is not compatible with MPM Prefork and that mod_php is only compatible with MPM Prefork.
- Change the MPM handler to Event in `/etc/httpd/conf.modules.d/00-mpm.conf`
- Enable php-fpm (should be already installed) with `systemctl enable --now php-fpm`
- Add `Protocols h2 http/1.1` to the vhosts or to the httpd main config
- Add the proxy pass rule to the vhosts, e.g. `ProxyPassMatch ^/(.*\.php(/.*)?)$ unix:/run/php-fpm/www.sock|fcgi://localhost/var/www/html/nextcloud/`

## Configure MariaDB
- Change default User/PW: root/root

## Configure Ampache
- Access the ampache address in the browser and follow the on-screen instructions. No not add a catalog until all the config is done.
- If Ampache complains that it can't connect to the database, you may need to copy the config file from the repo, set `use_auth = false` temporarily in order to create the first user from the app.
- If Ampache complains that the config file is unreadeable, press the orange "Write" button.
- Edit the config file with `nano /var/www/html/ampache/config/ampache.cfg.php`
  - Set `album_art_min_width = 255` and `album_art_min_height = 255`
  - Set `show_similar = "true"`
  - Set the LastFM API Key & Secret

## Configure Wallabag
- Configure MariaDB in app/config/parameters.yml
- Change default User/PW: wallabag/wallabag

## Configure Nextcloud
- From the browser, type the address of the nextcloud server and execute `setup-nextcloud.php`
- Follow the on-screen instructions to complete the setup.
- Before loging in for the first time, make sure to setup the data folder and storage options correctly.
- Once logged in...
  - Go to Personnal Settings and set the admin email address
  - Go to Admin -> Additional Settings and...
    - Setup email config: Mode=SMTP, Encryption=SSL/TLS, Server=smtp.gmail.com, Port=465, as well as your credentials
    - Increase the maximum file size as needed

## Tweak Selinux
If SElinux is causing issues, set permissive mode in order to [audit](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Security-Enhanced_Linux/sect-Security-Enhanced_Linux-Fixing_Problems-Allowing_Access_audit2allow.html) and make changes to the problematic polixies in `/etc/selinux/config`.
