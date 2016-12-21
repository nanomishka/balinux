#!/bin/bash

# CHECK IS USER ROOT
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user for execute this script" 2>&1
  exit 1
fi

fuser -vki /var/lib/dpkg/lock

apt-get install apache2 sysstat -y

# apache2 enable mod_cgi
ln -s /etc/apache2/mods-available/cgid* /etc/apache2/mods-enabled/.
cp balinux.conf /etc/apache2/sites-available/
rm /etc/apache2/sites-enabled/*
ln -s /etc/apache2/sites-available/balinux.conf /etc/apache2/sites-enabled/.
mkdir /var/www/balinux
cp sysinfo /var/www/balinux/
service apache2 restart

vmstat 1 > /var/www/balinux/cpu &
