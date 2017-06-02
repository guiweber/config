# Ampache server configuration
These are instructions to configure Fedora webserver running Ampache, Owncloud and Wallbagger on VirtualBox. At the time of writing, Fedora 25 is used.

## Prerequisites
- Install Fedora Server (the NetInstall iso provides the option)
- Configure port forwarding in your internet router and through VirtualBox

## Run config bash file
- Make sure the guest additions CD is inserted into virtual box
- Run the following commands as su:
 ```
 wget https://goo.gl/LCs85o -O cfg.sh
 bash cfg.sh
```
- change the passwords for the mysql config and then execute the file as su

## Configure Ampache
- Edit ampache.cfg.php with vi in /var/www/config in the docker container and change the following settings if needed
  - use_auth = true
  - default_auth_level = user
  - allow_public_registration = false
- Copy the music to /home/media/music on the host
- Change the permissions of /home/media recursively to 755
- You can now connect to the webserver and follow the instructions on screen
  - The mysql host is "maria"
  - The mysql root user is "admin" with the password specified
  - Create a catalog with path /home/media/music
