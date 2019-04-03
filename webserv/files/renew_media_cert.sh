cd /etc/httpd/conf.d
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/media.conf
systemctl restart httpd
certbot --apache -n --agree-tos -d media.stematics.net

rm media.conf -f
wget https://raw.githubusercontent.com/guiweber/config/master/webserv/files/redirects.conf
systemctl restart httpd
