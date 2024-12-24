#!/bin/bash
# -----------------------------------------
# install rfriends for ubuntu
# -----------------------------------------
# 3.0 2023/06/23
# 3.1 2023/07/10 remove chromium-browser
# 3.2 2023/07/12 renew
# 3.3 2023/08/04 add p7zip-full
# 3.4 2024/02/23 full
# 3.5 2024/02/24 add openssh-server
# 3.6 2024/10/29 add webdav
# 3.7 2024/11/04 add dirindex.css
# 4.0 2024/12/13 github
# 4.1 2024/12/24 fix
ver=4.1
# -----------------------------------------
echo
echo rfriends3 for ubuntu $ver
echo
# -----------------------------------------
dir=$(cd $(dirname $0);pwd)
user=`whoami`
userstr="s/rfriendsuser/${user}/g"
if [ -z $HOME ]; then
  homedir=`sh -c 'cd && pwd'`
else
  homedir=$HOME
fi
#
SITE=https://github.com/rfriends/rfriends3/releases/latest/download
SCRIPT=rfriends3_latest_script.zip
# -----------------------------------------
ar=`dpkg --print-architecture`
bit=`getconf LONG_BIT`
echo
echo architecture is $ar $bit bits .
echo user is $user .
echo current directry is $dir
echo home directry is $homedir
# -----------------------------------------
echo
echo install tools
echo
#
sudo apt-get update && sudo apt-get -y install \
unzip p7zip-full nano vim dnsutils iproute2 tzdata \
at cron wget curl atomicparsley \
php-cli php-xml php-zip php-mbstring php-json php-curl php-intl \
ffmpeg

sudo apt-get -y install chromium-browser 
sudo apt-get -y install samba
sudo apt-get -y install lighttpd lighttpd-mod-webdav php-cgi
sudo apt-get -y install openssh-server
# -----------------------------------------
# .vimrcを設定する
# -----------------------------------------
cd $homedir
mv -n .vimrc .vimrc.org
cat <<EOF > .vimrc
set encoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set fileformats=unix,dos,mac
EOF
chmod 644 .vimrc
# -----------------------------------------
echo
echo install rfriends3
echo
# -----------------------------------------
#rm $homedir/rfriends3_latest_script.zip
#wget http://rfriends.s1009.xrea.com/files3/rfriends3_latest_script.zip -O $homedir/rfriends3_latest_script.zip
#unzip -q -o -d $homedir $homedir/rfriends3_latest_script.zip

cd $homedir
rm -f $SCRIPT
wget $SITE/$SCRIPT
unzip -q -o $SCRIPT
# -----------------------------------------
echo
echo configure samba
echo
# -----------------------------------------
sudo mkdir -p /var/log/samba
sudo chown root.adm /var/log/samba

mkdir -p $homedir/smbdir/usr2/

sudo cp -p /etc/samba/smb.conf /etc/samba/smb.conf.org
sudo sed -e ${userstr} $dir/smb.conf.skel > $dir/smb.conf
sudo cp -p $dir/smb.conf /etc/samba/smb.conf
sudo chown root:root /etc/samba/smb.conf
# -----------------------------------------
echo
echo configure usrdir
echo
# -----------------------------------------
mkdir -p $homedir/tmp/
sed -e ${userstr} $dir/usrdir.ini.skel > $homedir/rfriends3/config/usrdir.ini
# -----------------------------------------
echo
echo configure lighttpd
echo
# -----------------------------------------
sudo cp -p /etc/lighttpd/conf-available/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf.org
sudo sed -e ${userstr} $dir/15-fastcgi-php.conf.skel > $dir/15-fastcgi-php.conf
sudo cp -p $dir/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf
sudo chown root:root /etc/lighttpd/conf-available/15-fastcgi-php.conf

sudo cp -p /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.org
sudo sed -e ${userstr} $dir/lighttpd.conf.skel > $dir/lighttpd.conf
sudo cp -p $dir/lighttpd.conf /etc/lighttpd/lighttpd.conf
sudo chown root:root /etc/lighttpd/lighttpd.conf

mkdir -p $homedir/lighttpd/uploads/
cd $homedir/rfriends3/script/html
ln -nfs temp webdav
cd $homedir
sudo lighttpd-enable-mod fastcgi
sudo lighttpd-enable-mod fastcgi-php
# -----------------------------------------
# systemd or service
#
# -----------------------------------------
sudo systemctl enable smbd
sudo systemctl enable lighttpd
sudo systemctl enable atd
sudo systemctl enable cron
#
#sudo service smbd restart
#sudo service lighttpd restart
#sudo service atd restart
#sudo service cron restart
# -----------------------------------------
#ip=`ip -4 -br a`
#echo
#echo ip address is $ip .
#echo
#echo visit rfriends at http://xxx.xxx.xxx.xxx:8000 .
#echo
# -----------------------------------------
cd $homedir
port=8000
ip=`sh $homedir/rfriends3/getIP.sh`
server=${ip}:${port}
echo
echo ブラウザで、http://$server にアクセスしてください。
echo
# -----------------------------------------
# finish
# -----------------------------------------
echo finished
# -----------------------------------------
