#!/bin/bash
# Script for installing freepbx

## 1. Install dependencies
sudo yum -y update
sudo yum -y install lynx tftp-server unixODBC mysql-connector-odbc mariadb-server mariadb \
  httpd ncurses-devel sendmail sendmail-cf sox newt-devel libxml2-devel libtiff-devel \
  audiofile-devel gtk2-devel subversion kernel-devel git crontabs cronie \
  cronie-anacron wget vim uuid-devel sqlite-devel net-tools gnutls-devel python-devel texinfo \
  libuuid-devel

## 2. PHP Installation
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

sudo yum remove php*
sudo yum -y install php56w php56w-pdo php56w-mysql php56w-mbstring php56w-pear php56w-process \ 
php56w-xml php56w-opcache php56w-ldap php56w-intl php56w-soap

## 3. Nodejs Installation

sudo curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
sudo yum install -y nodejs

## 4. Mysql configuration

sudo systemctl enable mariadb.service
sudo systemctl start mariadb

sudo mysql -e "UPDATE mysql.user SET Password=PASSWORD('freepbxuser') WHERE User='root'"
sudo mysql -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -e "DROP DATABASE IF EXISTS test"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
sudo mysql -e "FLUSH PRIVILEGES"

## 5. Httpd Configuration

sudo systemctl enable httpd.service
sudo systemctl start httpd.service

## 6. Installing peer requirements

sudo pear install Console_Getopt

## 7. Apache Modifications

sudo sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini
sudo sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd.service

## 8. Freepbx configuration

cd /usr/src
sudo wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-15.0-latest.tgz
sudo tar xfz freepbx-15.0-latest.tgz
sudo rm -f freepbx-15.0-latest.tgz
cd freepbx
sudo ./start_asterisk start
sudo ./install -n --dbuser root --dbpass freepbxuser
