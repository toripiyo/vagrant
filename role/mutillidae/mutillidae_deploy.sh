#! /bin/bash

apt-get update
apt-get install -y unzip
apt-get install -y apache2
# http://qiita.com/niku_uchi/items/b922de3fd1e770644928
echo "mysql-server mysql-server/root_password password my_password" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password my_password" | debconf-set-selections
apt-get install -y mysql-server libapache2-mod-auth-mysql php5-mysql php5-curl
apt-get install -y php5 libapache2-mod-php5 php5-mcrypt
test -f /usr/local/src/download || wget https://sourceforge.net/projects/mutillidae/files/latest/download -P /usr/local/src
test -d /var/www/html/mutillidae || unzip -d /var/www/html /usr/local/src/download
# update MySQLHandler.php file
test -f /var/www/html/mutillidae/classes/MySQLHandler.php.orig || cp -p /var/www/html/mutillidae/classes/MySQLHandler.php{,.orig}
perl -pi -e 's;(\$mMySQLDatabasePassword) = .*;$1 = "my_password"\;;g' /var/www/html/mutillidae/classes/MySQLHandler.php
# enable HTTPS
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=JP/ST=Tokyo/L=Ota-ku/O=Cat Inc./OU=Development/CN=192.168.33.10/emailAddress=admin@localhost" -keyout /etc/ssl/private/mutillidae-selfsigned.key -out /etc/ssl/certs/mutillidae-selfsigned.crt
test -f /etc/apache2/sites-available/default-ssl.conf.orig || cp -p /etc/apache2/sites-available/default-ssl.conf{,.orig}
perl -pi -e 's;(^\s*SSLCertificateFile\s*).*;$1/etc/ssl/certs/mutillidae-selfsigned.crt;g' /etc/apache2/sites-available/default-ssl.conf
perl -pi -e 's;(^\s*SSLCertificateKeyFile\s*).*;$1/etc/ssl/private/mutillidae-selfsigned.key;g' /etc/apache2/sites-available/default-ssl.conf
chown www-data:www-data /etc/ssl/certs/mutillidae-selfsigned.crt
chown www-data:www-data /etc/ssl/private/mutillidae-selfsigned.key
a2enmod ssl
a2enmod headers
a2ensite default-ssl
service apache2 restart