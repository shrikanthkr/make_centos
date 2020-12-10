#!/bin/bash
# Script for installing asterisk

## 1. Install Dependencies

setenforce 0
sed -i 's/\(^SELINUX=\).*/\SELINUX=permissive/' /etc/selinux/config
yum install -y git wget vim  net-tools sqlite-devel psmisc ncurses-devel libtermcap-devel \
newt-devel libxml2-devel libtiff-devel gtk2-devel libtool libuuid-devel subversion kernel-devel \
kernel-devel-$(uname -r) crontabs cronie-anacron

## 2. Grab and Install Asterisk and Configure the selections

cd /usr/src/
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz
tar xvfz asterisk-16-current.tar.gz
rm -f asterisk-*-current.tar.gz
cd asterisk-*
contrib/scripts/install_prereq install
./configure --libdir=/usr/lib64 --with-pjproject-bundled --with-jansson-bundled
contrib/scripts/get_mp3_source.sh
make menuselect.makeopts
menuselect/menuselect --enable app_macro menuselect.makeopts	
make
make install
make samples
make config
ldconfig

## 3. Change Ownerships to asterisk specific user

groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
usermod -aG audio,dialout asterisk
chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk

sed -i -e '/AST_USER/ s/^.//' /etc/sysconfig/asterisk
sed -i -e '/AST_GROUP/ s/^.//' /etc/sysconfig/asterisk
sed -i -e '/rungroup/ s/^.//' /etc/asterisk/asterisk.conf
sed -i -e '/runuser/ s/^.//' /etc/asterisk/asterisk.conf

## 4. Enable service on startup

systemctl restart asterisk
systemctl enable asterisk

