# Ampache server configuration
These are instructions to configure Fedora webserver running Ampache, Owncloud and Wallbagger on VirtualBox. At the time of writing, Fedora 25 is used.

## Prerequisites
- Install Fedora Server (the NetInstall iso provides the option)
- Configure port forwarding in your internet router and through VirtualBox

## Run config bash file
- Make sure the guest additions CD is inserted into virtual box
- Run the following commands as su:
 ```bash
 wget https://goo.gl/LCs85o -O cfg.sh && bash cfg.sh | tee cfg.log
```

## Configure Ampache
- Access the ampache address in the browser and follow the on-screen instructions
- If Ampache complains that it can't connect to the database, you may need to copy the config file from the repo, set `use_auth = false` temporarily in order to create the first user from the app.
- If need be, edit the config file with `nano /var/www/config/ampache.cfg.php/
