#!/bin/bash

echo "###############################################################"
echo "#                                                             #"
echo "#                        Codex 1 (Alpha)                      #"
echo "#                                                             #"
echo "###############################################################"

ARCH=`uname -m`

rm -f /root/codex-install/install.log > /dev/null 2>&1

cd /root

echo ""
echo "WARNING: This installer must be run from /root/codex-install."
read -p "Would you like to continue? (y/n): " GOODPATH
if [ $GOODPATH == "n" ]; then
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
		echo "Installing MongoDB" >> /root/codex-install/install.log 2>&1
		cd /root/codex-install
		cp /root/codex-install/mongodb.repo /etc/yum.repos.d/ >> /root/codex-install/install.log 2>&1
		yum install -y mongodb-org >> /root/codex-install/install.log 2>&1
		echo "done."
	fi
else
	echo ""
	echo "Instructions on how to install MongoDB can be found at mongoDB.org."
	echo ""
fi

if [ $CODEX == "y" ]; then
	echo "Installing Codex" >> /root/codex-install/install.log 2>&1
	echo ""
	echo -n "Installing dependencies..."
	yum install -y python wget gcc-c++ make >> /root/codex-install/install.log 2>&1
	echo "done."
	cd /
	echo -n "Getting Codex source code..."
	wget http://coldblue-usa.com/repo/codex_1_0_alpha.tar.gz >> /root/codex-install/install.log 2>&1
	tar -zxvf codex_1_0_alpha.tar.gz >> /root/codex-install/install.log 2>&1
	rm -f codex_1_0_alpha.tar.gz
	echo "done."
	echo ""
	echo "Configuring Codex for this machine..."
	read -p "Type the name of the machine's ethernet port: " ETH
	ifconfig $ETH | grep "inet addr" > /root/codex-install/eth
	python /root/codex-install/config.py 
	rm -f /root/codex-install/eth
	echo "Done configuring."
	cd /root
	echo ""
	echo -n "Installing Python + pip..."
	wget https://bootstrap.pypa.io/get-pip.py >> /root/codex-install/install.log 2>&1
	chmod +x get-pip.py >> /root/codex-install/install.log 2>&1
	python ./get-pip.py >> /root/codex-install/install.log 2>&1
	rm -f get-pip.py >> /root/codex-install/install.log 2>&1
	pip install pymongo >> /root/codex-install/install.log 2>&1
	echo "done."
	echo ""
	echo -n "Installing Node.js..."
	curl -sL https://rpm.nodesource.com/setup | bash - >> /root/codex-install/install.log 2>&1
	yum install -y nodejs >> /root/codex-install/install.log 2>&1
	echo "done."
	echo ""
	echo -n "Installing NodeJS modules..."
	cd /root
	git clone git://github.com/isaacs/npm.git >> /root/codex-install/install.log 2>&1
	make install >> /root/codex-install/install.log 2>&1
	cd /codex
	npm install >> /root/codex-install/install.log 2>&1
	echo "done."
	echo ""
	echo -n "Setting security settings..."
	service iptables stop >> /root/codex-install/install.log 2>&1
	service ip6tables stop >> /root/codex-install/install.log 2>&1
	chkconfig iptables off >> /root/codex-install/install.log 2>&1
	chkconfig ip6tables off >> /root/codex-install/install.log 2>&1
	echo "done."
fi
echo ""
echo "Finished up. Exiting."
touch /codex/log/node_server.log
touch /codex/log/angularjs.log
echo "Install log at /root/codex-install/install.log"
echo "Install complete." >> /root/codex-install/install.log 2>&1
echo ""
read -p "Would you like to start the database engine now? (y/n): " STARTUP
if [ $STARTUP == 'y' ]; then
	service mongod start
fi
