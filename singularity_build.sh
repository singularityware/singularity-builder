#!/bin/bash
#Singularity Builder
#Singularity: Application containers for Linux http://singularity.lbl.gov/
# For Build + install do
# sudo ./singularity_build.sh build install
# If you have all that's needed simply go for
# sudo ./singularity_build.sh install
# To Update do
# sudo ./singularity_build.sh update

if [ "$#" -lt 1 ]
then
echo  "Please insert at least one argument"
fi

for arg in $@
do
case "$arg" in
	"build")
	ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
	if [ -f /etc/debian_version ]; then
    	apt-get update > /tmp/.install-log
	apt-get -y install git \
                   build-essential \
                   libtool \
                   autotools-dev \
                   automake \
                   autoconf \
                   debootstrap \
                   yum \
                   python3-pip >> /tmp/.install-log

	elif [ -f /etc/redhat-release ]; then
	rhdist=$(cat /etc/redhat-release | awk '{print $1;}')
		case "$rhdist" in
		"CentOS")
        	yum update > /tmp/.install-log
		yum -y group install 'Development Tools'
		yum -y install git \
                   	libtool \
                   	automake make \
                   	autoconf \
                   	debootstrap \
                   	python3-pip >> /tmp/.install-log
			;;
		"Fedora")
        	dnf update #> /tmp/.install-log
		dnf -y group install 'Development Tools'
		dnf -y install git \
                   	libtool \
                   	automake \
                   	autoconf \
                   	debootstrap \
                   	python3-pip #>> /tmp/.install-log
			;;
	esac
	fi
	;;
	"install")	
# Install Singularity from Github
	cd /tmp && git clone http://www.github.com/singularityware/singularity 
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
	echo "SingularityApp successfully installed"
	;;
	"update")
# Update Singularity from Github
	whereis singularity >> /tmp/singularitybins.out
	sed -e 's/singularity://g' /tmp/singularitybins.out | rm -rf
	cd /tmp && git clone http://www.github.com/singularityware/singularity 
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
	echo "SingularityApp successfully installed"
	;;
	"install-devel")	
# Install Singularity-Development branch from Github
	cd /tmp && git clone -b development http://www.github.com/singularityware/singularity 
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
	echo "SingularityApp successfully installed"	
	;;
	"update-devel")
# Update Singularity-Development branch from Github
	whereis singularity >> /tmp/singularitybins.out
	sed -e 's/singularity://g' /tmp/singularitybins.out | rm -rf
	cd /tmp && git clone -b development http://www.github.com/singularityware/singularity
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
	echo "SingularityApp successfully installed"
	;;
esac
done
