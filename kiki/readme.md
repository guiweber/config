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

