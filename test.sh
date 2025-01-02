#!/bin/bash
# =========================================
# install rfriends for ubuntu
# =========================================
# 3.0 2023/06/23
# 3.1 2023/07/10 remove chromium-browser
# 3.2 2023/07/12 renew
# 3.3 2023/08/04 add p7zip-full
# 3.4 2024/02/23 full
# 3.5 2024/02/24 add openssh-server
# 3.6 2024/10/29 add webdav
# 3.7 2024/11/04 add dirindex.css
# 4.0 2024/12/13 github
# 4.2 2024/12/29 fix
# 4.3 2025/01/03 sep
ver=4.3
# -----------------------------------------
echo
echo rfriends3 for ubuntu $ver
echo `date`
echo
# -----------------------------------------
optlighttpd="on"
optsamba="on"
export optlighttpd
export optsamba
#
sh ubuntu.sh
# -----------------------------------------
# finish
# -----------------------------------------
echo `date`
echo finished rfriends_ubuntu
# -----------------------------------------
