#!/bin/sh
# -----------------------------------------
# install rfriends for termux easy
# -----------------------------------------
# 1.00 2023/08/01 easy
# 1.01 2023/08/04 add ncpamixer,p7zip
# 1.10 2024/07/30 easy
# 1.30 2024/10/17 firetv
# 1.40 2024/10/23 ip -> ifconfig
# 2.00 2024/11/04 lighttpd,webdav
# 3.00 2024/12/13 for github
ver=3.00
# 
# toolinstall
# rfriends install
#===========================================================
echo
echo rfriends for termux $ver
echo

PREFIX=/data/data/com.termux/files/usr
HOME=/data/data/com.termux/files/home
SITE=http://rfriends.s1009.xrea.com/files3
dir=`pwd`
#===========================================================
termux-setup-storage
#
pkg update -y 
pkg upgrade -y 
pkg install -y wget

echo
echo ツールをインストール
echo

cd ~/

pkg install -y \
wget curl unzip p7zip nano vim dnsutils iproute2 openssh \
ffmpeg atomicparsley php at cronie \
termux-services termux-auth

#pkg install -y x11-repo
#pkg install -y ffplay
#pkg install -y ncpamixer

#pkg install -y chromium-browser
#===========================================================
echo
echo rfriends3 をインストール
echo

cd $HOME

if [ -d ./rfriends3 ]; then
	read -p "すでにrfriendsがインストールされていますが、削除しますか？　(y/N) " ans

	case "$ans" in
  		"y" | "Y" )
			rm -rf ./rfriends3
			echo "rfriendsを削除しました。"
			echo 
    			;;
  		* )
			echo 
    			;;
	esac
fi

rm -f rfriends3_latest_script.zip
wget $SITE/rfriends3_latest_script.zip
unzip -q -o rfriends3_latest_script.zip

sed 's/rfriends_name = ""/rfriends_name = "termux"/' $HOME/rfriends3/script/rfriends.ini > $HOME/rfriends3/config/rfriends.ini
#===========================================================
# for cron
#
mkdir $HOME/.cache
rm -f $HOME/rfriends3/script/crontab
cat <<EOF | tee $HOME/rfriends3/script/crontab > /dev/null
# rfriends crontab template for termux (2024/11/03)
#
#SHELL=/bin/sh
#PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
BASE_DIR=/data/data/com.termux/files/home/rfriends3
# m h  dom mon dow   command
#
25 05 * * * sh $BASE_DIR/script/ex_rfriends.sh
# second job
#
25 17 * * * sh $BASE_DIR/script/ex_rfriends.sh
EOF
#===========================================================
# for vim
#
cat <<EOF | tee $HOME/.vimrc > /dev/null
set encoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set fileformats=unix,dos,mac
EOF
#===========================================================
# svenable
#
rm -f $HOME/svenable.sh
cat <<'EOF' | tee $HOME/svenable.sh > /dev/null
#!/bin/sh
# -----------------------------------------
# install rfriends for termux easy
# -----------------------------------------
# 1.11 2024/07/31 easy
# 2.00 2024/11/03 add lighttpd
#=======================================
echo
echo sv-enable 2.00
echo
echo 以下の5つのコマンドを実行します。
echo
echo sv-enable atd
echo sv-enable crond 
echo sv-enable sshd
echo sv-enable lighttpd
echo termux-wake-lock
echo
#=======================================
sv-enable atd
sv-enable crond
sv-enable sshd
sv-enable lighttpd
# 
termux-wake-lock
#
echo
cd ~/
port=8000
ip=`sh rfriends3/getIP.sh`
server=${ip}:${port}
echo
echo ブラウザで、http://$server にアクセスしてください。
echo
EOF
#===========================================================
# usrdir.ini
#
mkdir $HOME/storage/downloads/usr
#
#mkdir $HOME/storage/media-1/usr
#
cat <<EOF | tee $HOME/rfriends3/config/usrdir.ini > /dev/null
; Termux  : ;省略時（ダウンロードディレクトリ）
;           usrdir = "/data/data/com.termux/files/home/storage/downloads/usr/"
;           ;microSDからは：Android/media/com.termux/
;           usrdir = "/data/data/com.termux/files/home/storage/media-1/"
;           tmpdir   = ''
; -------------------------------------
[usrdir]
; Internal media
usrdir="/data/data/com.termux/files/home/storage/downloads/usr/"
;
; microSD
;usrdir = "/data/data/com.termux/files/home/storage/media-1/"
;
tmpdir = ""
EOF
#===========================================================
# buildinserver -> lighttpd のため廃止 2024/11/03
#
#rm $HOME/xrfriends3
#cat <<EOF | tee $HOME/xserver.sh > /dev/null
#!/bin/sh
# -----------------------------------------
# rfriends 簡単起動
# -----------------------------------------
# 1.01 2023/08/01
# 1.03 2024/10/23
#
#cd ~/rfriends3
# -----------------------------------------
#sh rf3server.sh
# -----------------------------------------
#EOF

#chmod +x ~/xserver.sh
#===========================================================
# lighttpd + fastcgi + webdav
#===========================================================

LCONF=$PREFIX/etc/lighttpd

#HTDOCS=$PREFIX/var/www/htdocs
HTDOCS=$HOME/rfriends3/script/html

pkg install -y lighttpd

#mkdir $PREFIX/var/run
#mkdir $PREFIX/etc/lighttpd

mkdir $PREFIX/var/log/lighttpd
mkdir $PREFIX/var/lib/lighttpd
mkdir -p $PREFIX/var/cache/lighttpd
mkdir $HOME/sockets

mkdir -p $HTDOCS/temp
ln -s $HTDOCS/temp $HTDOCS/webdav

mv -n $LCONF/lighttpd.conf $LCONF/lighttpd.conf.org
mv -n $LCONF/modules.conf  $LCONF/modules.conf.org
mv -n $LCONF/conf.d/fastcgi.conf    $LCONF/conf.d/fastcgi.conf.org

cd $dir

cp -f lighttpd.conf $LCONF/lighttpd.conf
cp -f modules.conf  $LCONF/modules.conf
cp -f fastcgi.conf  $LCONF/conf.d/fastcgi.conf 

sed -i 's/#webdav.is-readonly/webdav.is-readonly/'       $LCONF/conf.d/webdav.conf
sed -i 's/#webdav.sqlite-db-name/webdav.sqlite-db-name/' $LCONF/conf.d/webdav.conf
sed -i 's/webdav.sqlite-db-name/#webdav.sqlite-db-name/' $LCONF/conf.d/webdav.conf
sed -i 's/#dir-listing.activate/dir-listing.activate/'   $LCONF/conf.d/dirlisting.conf
sed -i 's/#dir-listing.external-css/dir-listing.external-css' $LCONF/conf.d/dirlisting.conf
#===========================================================
echo
echo 1. exit で termux を終了
echo 2. 再度 termux を起動
echo 3. sh svenable.sh を実行
echo
#===========================================================
# 終了
# -----------------------------------------
echo
echo finished
# -----------------------------------------
