#!/bin/bash

# CHECK IS USER ROOT
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user for execute this script" 2>&1
  exit 1
fi

apt-get install nginx apache2 sysstat -y

# apache2 enable mod_cgi
cd /etc/apache2/mods-enabled/
sudo ln -s ../mods-available/cgid* .
