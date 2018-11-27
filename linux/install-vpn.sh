#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

sudo apt-get update

read -p "Install Shadowsocks server and \"chacha20\" encryption? [yes/no]: " ans

if [ "$ans" = "yes" ]; then
	sudo apt-get -y --force-yes install python-gevent python-pip python-m2crypto
	pip install shadowsocks
	wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
	tar zxf LATEST.tar.gz
	cd libsodium* && ./configure && make && make install && cd ..
	rm -rf LATEST.tar.gz libsodium*
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
fi

read -p "Install serverSpeeder? [yes/no]: " ans

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

read -p "Install L2TP server? [yes/no]: " ans

if [ "$ans" = "yes" ]; then
	wget https://git.io/vpnsetup -O vpnsetup.sh && sh vpnsetup.sh
	rm vpnsetup.sh
fi

read -p "Optimize sysctl for TCP connection? [yes/no]: " ans

if [ "$ans" = "yes" ]; then
	echo "* soft nofile 51200" > /etc/security/limits.conf
	echo "* hard nofile 51200" > /etc/security/limits.conf
	ulimit -n 51200
	sysctl net.ipv4.tcp_available_congestion_control
	/sbin/modprobe tcp_hybla
	printf "\
	fs.file-max = 51200\n\
	net.core.rmem_max = 67108864\n\
	net.core.wmem_max = 67108864\n\
	net.core.netdev_max_backlog = 250000\n\
	net.core.somaxconn = 4096\n\
	net.ipv4.tcp_syncookies = 1\n\
	net.ipv4.tcp_tw_reuse = 1\n\
	net.ipv4.tcp_tw_recycle = 0\n\
	net.ipv4.tcp_fin_timeout = 30\n\
	net.ipv4.tcp_keepalive_time = 1200\n\
	net.ipv4.ip_local_port_range = 10000 65000\n\
	net.ipv4.tcp_max_syn_backlog = 8192\n\
	net.ipv4.tcp_max_tw_buckets = 5000\n\
	net.ipv4.tcp_fastopen = 3\n\
	net.ipv4.tcp_mem = 25600 51200 102400\n\
	net.ipv4.tcp_rmem = 4096 87380 67108864\n\
	net.ipv4.tcp_wmem = 4096 65536 67108864\n\
	net.ipv4.tcp_mtu_probing = 1\n\
	net.ipv4.tcp_congestion_control = hybla" > /etc/sysctl.conf
	sysctl -p
fi

echo "Installation completed, bye!";
