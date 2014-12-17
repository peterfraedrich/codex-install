#!/bin/bash

ARCH=`uname -m`

rm -f /root/codex-install/install.log > /dev/null 2>&1

cd /root

echo ""
echo "WARNING: This installer must be run from /root/codex-install."
read -p "Would you like to continue? (y/n):" DIR
if [$DIR == "n" ]: then
	exit
fi

echo ""
echo "You must have internet connectivity to install CODEX with this installer."
read -p "Would you like to continue? (y/n): " INTERNET
if [ $INTERNET == "n" ]; then
	exit
fi

echo ""
read -p "Install Codex on this machine? (y/n): " CODEX
read -p "Install MongoDB on this machine? (y/n): " DB

if [ $DB == "y" ]; then
	if [ $ARCH != "x86_64" ]; then
		echo ""
		read -p "DB must be installed on x86_64 architecture. Do you wish to continue the CODEX install?" CONT
		if [ $CONT == "n" ]; then
			exit
		fi
	else
		echo ""
		echo -n "Installing MongoDB backend..."
		echo "Installing MongoDB" > /root/codex-install/install.log
		cd /root/codex-install
		cp /root/codex-install/mongodb.repo /etc/yum.repos.d/ > /root/codex-install/install.log
		yum install -y mongodb-org > /root/codex-install/install.log
		echo "done."
	fi
else
	echo ""
	echo "Instructions on how to install MongoDB can be found at mongoDB.org."
	echo ""
fi

if [ $CODEX == "y" ]; then
	echo "Installing Codex" > /root/codex-install/install.log
	echo ""
	echo -n "Installing dependencies..."
	yum install -y python wget gcc-c++ make > /root/codex-install/install.log
	echo "done."
	cd /
	echo -n "Getting Codex source code..."
	wget http://coldblue-usa.com/repo/codex_1_0_alpha.tar.gz > /root/codex-install/install.log
	tar -zxvf codex_1_0_alpha.tar.gz > /root/codex-install/install.log
	rm -f codex_1_0_alpha.tar.gz
	echo "done."
	cd /root
	echo -n "Installing Python + pip..."
	wget https://bootstrap.pypa.io/get-pip.py > /root/codex-install/install.log
	chmod +x get-pip.py > /root/codex-install/install.log
	python ./get-pip.py > /root/codex-install/install.log
	rm -f get-pip.py > /root/codex-install/install.log
	pip install pymongo
	echo "done."
	echo -n "Installing Node.js..."
	curl -sL https://rpm.nodesource.com/setup | bash - > /root/codex-install/install.log
	yum install -y nodejs
	echo "done."
	echo -n "Installing NodeJS modules..."
	git clone git://github.com/isaacs/npm.git
	cd /codex/npm
	make install
	cd /codex
	npm install #> /dev/null 2>&1
	echo "done."
	echo -n "Setting security settings..."
	service iptables stop > /root/codex-install/install.log
	service ip6tables stop > /root/codex-install/install.log
	chkconfig iptables off > /root/codex-install/install.log
	chkconfig ip6tables off > /root/codex-install/install.log
	echo "done."
fi

echo "Finished up. Exiting."
echo "Install log at /root/codex-install/install.log"
echo "install complete." > /root/codex-install/install.log
