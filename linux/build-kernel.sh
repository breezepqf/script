#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [ `whoami` != "root" ]; then
	echo " Error: Run this script as root!" && exit 1
fi

if [ `uname` != "Linux" ]; then
	echo " Error: Run this script in linux!" && exit 1
fi

clear
echo "####################################################################"
echo "#                     Linux kernel installer                       #"
echo "#   This script, written by Alfred Liu, will guide you to build    #"
echo "# and install a linux kernel. If your machine failed to boot after #"
echo "# installation, it's none of my business.                          #"
echo "#   Anyway, enjoy yourself with linux!                             #"
echo "####################################################################"
echo
echo "Warning: KEEP DEFAULT, unless you know what you are doing!"
echo "Warning: Some early versions of linux kernel (such as v3.0) do not support old default configuration."
echo "Warning: If you are running in a virtual machine, make sure it supports the kernel version you wish to install."
echo
echo "Kernel version: `uname -r`"
echo "Distribution: `cat /etc/issue | grep -o '[^\/]*' | sed -n 1p`"
echo "GCC version: `gcc --version | grep gcc`"

# Change apt-get mirror site

rm -rf chmirror.sh
wget https://masterliu.net/scripts/chmirror.sh -q
bash chmirror.sh
rm -rf chmirror.sh

# Install dependencies

apt-get install -y linux-libc-dev libssl-dev kernel-package build-essential libncurses5-dev fakeroot bc curl xz-utils make

# Choose kernel mirror site

echo
echo "For better downloading speed, choose a mirror site of linux kernel:"
echo "[0]: https://www.kernel.org/pub/linux/kernel/"
echo "[1]: https://mirrors.aliyun.com/linux-kernel/"
echo "[2]: http://mirrors.xjtu.edu.cn/kernel/"
echo "[3]: others"
read -p "Make a choice: [0] " ans

mirror_site="https://www.kernel.org/pub/linux/kernel/"

if [ "$ans" = "1" ]; then
	mirror_site="https://mirrors.aliyun.com/linux-kernel/"
elif [ "$ans" = "2" ]; then
	mirror_site="http://mirrors.xjtu.edu.cn/kernel/"
elif [ "$ans" = "3" ]; then
	read -p "Enter your mirror site: " mirror_site
fi

# Show the version list

echo && echo "Fetching major version list..."
curl $mirror_site -s | grep -o '>v.*/' | grep -o '[0-9]\.[0-9x]' | column -s 1
read -p "Choose a major version: " major_version

echo && echo "Fetching minor version list..."
list=`curl ${mirror_site}v$major_version/ -s | grep -o '>li.*xz' | grep -o '[0-9].*[0-9]' | column -s 1`

if [ "$list" = "" ]; then
	echo "Could not get minor version list, did you enter a correct major version? " && exit 1
fi

echo "$list" && read -p "Choose a version: " minor_version

if [ "$minor_version" = "" ]; then
	echo "You MUST choose a version!" && exit 1
fi

# Remove old linux source directory

echo && echo "Checking directory /usr/src..."
kernel_src="/usr/src/linux-$minor_version"
old_linux_dir=`find /usr/src/ -path ${kernel_src}`

if [ "$old_linux_dir" != "" ]; then
	read -p "Old kernel source is found in $old_linux_dir, remove it? [Y/n] " ans
	case $ans in [nN][oO]|[nN]) 
		echo "Remove this directory, or this script won't continue."
		exit 1
	esac
	echo "Removing ${old_linux_dir}..."
fi

rm -rf $old_linux_dir

# Download linux kernel

cd /usr/src
kernel_src_tar=`find . -path "./linux-${minor_version}.tar.xz"`

if [ "$kernel_src_tar" != "" ]; then
	read -p "$kernel_src_tar found in local, extract it? [Y/n] " ans
	case $ans in [nN][oO]|[nN]) 
		rm -rf $kernel_src_tar
		echo && echo "Downloading linux $minor_version..."
		wget "${mirror_site}v${major_version}/linux-$minor_version.tar.xz" || exit 1
	esac
else
	echo && echo "Downloading linux $minor_version..."
	wget "${mirror_site}v${major_version}/linux-$minor_version.tar.xz" || exit 1
fi

# Decompress it

echo && echo "Extracting linux-$minor_version.tar.xz..."
tar -xvf linux-$minor_version.tar.xz > /dev/null || exit 1

# Kernel configuration

echo && echo "Configuring kernel..."
oldconfig=`find /boot -path '/boot/config*'`
oldconfig_num=`echo "$oldconfig" | wc -l`
echo "Found old linux kernel configuration files, load them?"
echo "[0]: No"

for i in $(seq $oldconfig_num); do
	oldconfig_nth=`echo "$oldconfig" | sed -n ${i}p`
	echo "[${i}]: Load $oldconfig_nth"
done

read -p "Make a choice: [0-$oldconfig_num] " ans

if [ "$ans" = "" ]; then
	ans="1";
fi

if [ "$ans" != "0" ]; then
	echo "Loading $oldconfig_nth..."
	cp `echo "$oldconfig" | sed -n ${ans}p` ${kernel_src}/.config
	olddefconfig=`make -C ${kernel_src} help | grep 'olddefconfig'`
	
	if [ "$olddefconfig" != "" ]; then
		read -p "Set new symbols to default? (make olddefconfig) [Y/n] " ans
		case $ans in [nN][oO]|[nN])
			olddefconfig=""
		esac
	fi

	if [ "$olddefconfig" != "" ]; then
		make -C ${kernel_src} olddefconfig || exit 1
	else
		make -C ${kernel_src} menuconfig || exit 1
	fi
else
	make -C ${kernel_src} allnoconfig > /dev/null || true
	echo
	echo "How to configure the kernel?"
	echo "[0]: Show the GUI menu (make menuconfig)"
	echo "[1]: New config with default from ARCH supplied defconfig (make defconfig)"
	echo "[2]: New config where all options are answered with no (make allnoconfig)"
	echo "[3]: New config where all options are accepted with yes (make allyesconfig)"
	echo "[4]: New config selecting modules when possible (make allmodconfig)"
	echo "[5]: New config with all symbols set to default (make alldefconfig)"
	read -p "Make a choice: [0-5] " ans

	if [ "$ans" = "0" ]; then
		make -C ${kernel_src} menuconfig || exit 1
	elif [ "$ans" = "1" ]; then
		make -C ${kernel_src} defconfig || exit 1
	elif [ "$ans" = "2" ]; then
		make -C ${kernel_src} allnoconfig || exit 1
	elif [ "$ans" = "3" ]; then
		make -C ${kernel_src} allyesconfig || exit 1
	elif [ "$ans" = "4" ]; then
		make -C ${kernel_src} allmodconfig || exit 1
	elif [ "$ans" = "5" ]; then
		make -C ${kernel_src} alldefconfig || exit 1
	else
		make -C ${kernel_src} menuconfig || exit 1
	fi
fi

echo && read -p "Configuration done, do you wish to view/modify it? [y/N] " ans
case $ans in [yY][eE][sS]|[yY])
	make -C ${kernel_src} menuconfig || exit 1
esac

# Preparetion for compiling

echo && echo "Getting cpu info..."
echo `cat /proc/cpuinfo | grep 'model name' | sed -n 1p`
echo `cat /proc/cpuinfo | grep 'cpu MHz' | sed -n 1p`
echo `cat /proc/cpuinfo | grep 'cpu cores' | sed -n 1p`
echo && read -p "How many processor cores to use? [1] " cpu_cores

if [ "$cpu_cores" = "" ]; then
	cpu_cores="1";
fi

# Always show grub menu when booting

echo && echo "Setting up grub menu..."
sed -i "/.*/s/GRUB_HIDDEN_TIMEOUT/#GRUB_#HIDDEN_TIMEOUT/g" /etc/default/grub
echo "GRUB_DISABLE_SUBMENU='y'" >> /etc/default/grub

# Start compiling

echo && echo "Compilation is ready to start."
echo "Warning: This operation can take a LONG time!"
read -p "Run in background? [y/N] " ans

cd ${kernel_src} && ${kernel_src}/scripts/config --disable DEBUG_INFO
cd ${kernel_src} && ${kernel_src}/scripts/config --disable CC_STACKPROTECTOR_STRONG

case $ans in [nN][oO]|[nN]|'')
	make -C ${kernel_src} -j $cpu_cores || exit 1
	make -C ${kernel_src} INSTALL_MOD_STRIP=1 modules_install -j $cpu_cores || exit 1
	make -C ${kernel_src} install -j $cpu_cores || exit 1

	read -p "Congratulations! Linux $minor_version has been installed, reboot now? [Y/n] " ans	
	case $ans in [nN][oO]|[nN]) 
		echo "Bye!" && exit 0
	esac

	reboot && exit 0
esac

nohup sh -c "cd ${kernel_src} && make -j $cpu_cores && make INSTALL_MOD_STRIP=1 modules_install -j $cpu_cores && make install && reboot" > /dev/null &
sleep 0.5

echo && echo "Job is running in background now."
echo "System will reboot automatically when everything is done."
exit 0
