# Ampache server configuration
These are instructions to configure a Dockerised Ampache server on VirtualBox under Fedora. At the time of writing, Fedora 25 is used.

## Prerequisites
- Install Fedora Server (the NetInstall iso provides the option)
- Configure port forwarding in your internet router and through VirtualBox

## Run config bash file
- Make sure the guest additions CD is inserted into virtual box
- Run the following commands:
 ```
 wget https://github.com/guiweber/config/blob/master/ampache/files/cfg.sh
 chmod +x cfg.sh
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


## To debug containers

Open a new bash in the container:
- docker exec -it container_name bash

See runing containers:
- docker ps 
