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

## Run certbot
- `certbot --apache`
- Note: For certbot to work, NO virtual host should be pre-configured to listen to port 443.

## Configure MariaDB
- Change default User/PW: root/root

## Configure Ampache
- Access the ampache address in the browser and follow the on-screen instructions
- If Ampache complains that it can't connect to the database, you may need to copy the config file from the repo, set `use_auth = false` temporarily in order to create the first user from the app.
- If Ampache complains that the config file is unreadeable, press the orange "Write" button.
- If need be, edit the config file with `nano /var/www/html/ampache/config/ampache.cfg.php`

## Configure Wallabag
- Configure MariaDB in app/config/parameters.yml
- Change default User/PW: wallabag/wallabag

## Configure Nextcloud
- From the browser, type the address of the nextcloud server and execute `setup-nextcloud.php`
- Follow the on-screen instructions to complete the setup.
