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
