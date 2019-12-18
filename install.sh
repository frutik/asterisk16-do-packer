#!/bin/bash

yum update -y
#yum upgrade

# setup selinux

setenforce=0
sed -i 's/enforcing/permissive/g' /etc/selinux/config


# alternative recommendation

#sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
#sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config

# https://stackoverflow.com/questions/45824220/how-to-run-menuselect-menuselect-command-via-bash-script
# https://wiki.asterisk.org/wiki/display/AST/Using+Menuselect+to+Select+Asterisk+Options
# https://linuxize.com/post/how-to-install-asterisk-on-ubuntu-18-04/

yum install -y kernel-header kernel-devel
yum install -y wget

curl -sSL https://repos.insights.digitalocean.com/install.sh | bash

cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz

tar xvfz dahdi-linux-complete-current.tar.gz
tar xvfz libpri-current.tar.gz
rm -f dahdi-linux-complete-current.tar.gz libpri-current.tar.gz
cd dahdi-linux-complete-*
make all
make install
make config
cd /usr/src/libpri-*
make
make install

#cd /usr/src

#wget -O jansson.tar.gz https://github.com/akheron/jansson/archive/v2.12.tar.gz

#tar vxfz jansson.tar.gz
#rm -f jansson.tar.gz
#cd jansson-*
#autoreconf -i
#./configure --libdir=/usr/lib64
#make
#make install

cd /usr/src

wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz

tar xvfz asterisk-16-current.tar.gz
rm -f asterisk-*-current.tar.gz
cd asterisk-*
contrib/scripts/install_prereq install
./configure --libdir=/usr/lib64 \
    --with-pjproject-bundled \
    --with-jansson-bundled \
    --without-radius \
    --without-x11 \
    --without-speex
contrib/scripts/get_mp3_source.sh

make menuselect.makeopts
#menuselect/menuselect \
#    --disable-category MENUSELECT_ADDONS \
#    --disable-category MENUSELECT_APPS \
#        --enable app_authenticate --enable app_cdr --enable app_celgenuserevent \
#        --enable app_channelredirect --enable app_chanisavail --enable app_chanspy

#make menuselect

make
make install
make config
make samples

ldconfig
#chkconfig asterisk off

groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
usermod -aG audio,dialout asterisk
chown -R asterisk.asterisk /etc/asterisk
chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
chown -R asterisk.asterisk /usr/lib64/asterisk

#$ sudo vim /etc/sysconfig/asterisk
#AST_USER="asterisk"
#AST_GROUP="asterisk"

#$ sudo vim /etc/asterisk/asterisk.conf
#runuser = asterisk ; The user to run as.
#rungroup = asterisk ; The group to run as.

systemctl enable asterisk

yum remove -y wget
