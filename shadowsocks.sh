#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

read -p "Install Shadowsocks server? [yes/no]: " ans

if [ "$ans" = "yes" ]; then
	sudo apt-get update
	sudo apt-get -y --force-yes install python-gevent python-pip python-m2crypto
	pip install shadowsocks
    wget https://raw.githubusercontent.com/afterthat97/scripts/master/shadowsocks.json -P /etc/
    ssserver -c /etc/shadowsocks.json -d start
    if ! grep -qs "Alfred's shadowsocks script" /etc/rc.local; then
        if [ -f /etc/rc.local ]; then
            sed --follow-symlinks -i '/^exit 0/d' /etc/rc.local
        else
            echo '#!/bin/sh' > /etc/rc.local
        fi
        echo "# Added by Alfred's shadowsocks script" >> /etc/rc.local
        echo "(/usr/local/bin/ssserver -c /etc/shadowsocks.json -d start)&" >> /etc/rc.local
        echo "exit 0" >> /etc/rc.local
    fi
    echo "Shadowsocks configuration is saved in /etc/shadowsocks.json"
fi

read -p "Install Server Speeder? [yes/no]: " ans

if [ "$ans" = "yes" ]; then
	linux_core=`dpkg -l | grep linux-image | awk -F' ' '{print $2}'`
	if [ "$linux_core" != "linux-image-3.13.0-24-generic" ]; then
		echo "Your Linux core does not match, it will be replaced it with 3.13.0-24.";
		read -p "Press Enter to continue...";
		apt-get -y --force-yes purge linux-image-.*generic
		apt-get -y --force-yes install linux-image-3.13.0-24-generic
		read -p "Reboot is required to continue, now? [yes/no] " ans
		echo "Run this script again when reboot is completed!";
		if [ "$ans" = "yes" ]; then
			reboot && exit
		else
			exit
		fi
	fi
	wget -N https://github.com/91yun/serverspeeder/raw/master/serverspeeder.sh
	bash serverspeeder.sh
	rm -rf 91yunserverspeeder/ 91yunserverspeeder.tar.gz serverspeeder.sh
fi

echo "Installation completed, bye!";
