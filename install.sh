#!/bin/bash

# CHECK IS USER ROOT
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user for execute this script" 2>&1
  exit 1
fi

apt-get install apache2 sysstat -y

# apache2 enable mod_cgi
ln -s /etc/apache2/mods-available/cgid* /etc/apache2/mods-enabled/.
cp balinux.conf /etc/apache2/sites-available/
ln -s /etc/apache2/sites-available/balinux.conf /etc/apache2/sites-enabled/.
sed -i '/Listen 80/cListen 5000' /etc/apache2/ports.conf
mkdir /var/www/balinux
cp index.sh /var/www/balinux/
service apache2 restart
