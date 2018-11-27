#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [ `whoami` != "root" ]; then
	echo " Error: Run this script as root!" && exit 1
fi

list="/etc/apt/sources.list"
last_mirror=`cat $list | grep -o '/[a-z]*\.[^/]*/' | grep -o '[^/]*' | sed -n 2p`
cnt_mirror=$last_mirror

echo
echo "Choose a mirror site for apt-get:"
echo "[0]: $last_mirror (current)"
echo "[1]: mirrors.aliyun.com"
echo "[2]: mirrors.xjtu.edu.cn"
echo "[3]: others"
read -p "Make a choice: [0] " ans

if [ "$ans" = "1" ]; then
	cnt_mirror="mirrors.aliyun.com"
	sed -i "/.*/s/${last_mirror}/${cnt_mirror}/g" $list
elif [ "$ans" = "2" ]; then
	cnt_mirror="mirrors.xjtu.edu.cn"
	sed -i "/.*/s/${last_mirror}/${cnt_mirror}/g" $list
elif [ "$ans" = "3" ]; then
	read -p "Enter your mirror site: " cnt_mirror
	sed -i "/.*/s/${last_mirror}/${cnt_mirror}/g" $list
fi

apt-get update
