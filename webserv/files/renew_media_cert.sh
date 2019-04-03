# Replaces media config so that port 80 is used and renews the cert
cd /etc/httpd/conf.d
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/media.conf
systemctl restart httpd
certbot --apache -n --agree-tos -d media.stematics.net

# Puts back original config in place
rm media.conf -f
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/redirects.conf
systemctl restart httpd

# Generates cert in pfx format and copies to share point for retrival
openssl pkcs12 -export -out certificate.pfx -inkey /etc/letsencrypt/live/media.stematics.net/privkey.pem -in /etc/letsencrypt/live/media.stematics.net/fullchain.pem -password pass:
cp certificate.pfx /media/sf_nextcloud_data
rm certificate.pfx
