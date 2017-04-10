#!/bin/bash
#Singularity Builder
#Singularity: containers for Linux http://singularity.lbl.gov/

if [ "$#" -lt 1 ];
then
echo "Singularity Builder: build, install, and update Singularity software. 
Support for Debian/Ubuntu, Centos/Fedora

USAGE: ./singularity_builder.sh <command> [options] ...

COMMANDS:
     all        setup, build, and install [sudo]
     setup     	install dependencies for your distribution [sudo]
     build      configure and make the installation, with optional --prefix
     install    make, and make install [sudo]
     update 	[sudo]

DEVELOPMENT:
   install-devel: equivalent to install, but using development branch 
   update-devel  equivalent to update, but using development branch

Examples:

  # Install dependencies, setup, build + install
  sudo ./singularity_build.sh all

  # Install dependencies, build + optional prefix
  sudo ./singularity_build.sh build --prefix=/my/path
 
  # If you already have dependencies, just install
  sudo ./singularity_build.sh install

  # Update an installation
  sudo ./singularity_build.sh update

Singularity: Application containers for Linux
For additional help, see http://singularity.lbl.gov/"
exit 1
fi

setup () {
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
}

remove () {
rm -rf $1/libexec/singularity
rm -rf $1/etc/singularity
rm -rf $1/include/singularity
rm -rf $1/lib/singularity
rm -rf $1/var/lib/singularity/
rm $1/bin/singularity
rm $1/bin/run-singularity
rm $1/etc/bash_completion.d/singularity 
rm $1/man/man1/singularity.1
}

for arg in $@
do
case "$arg" in
	"setup")
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root."
	exit 1
	else
	setup
	fi
	;;
	"build")
# Build configure and make the installation, with optional --prefix
	cd /tmp && git clone http://www.github.com/singularityware/singularity 
	if [ $2 ];
	then	
	cd /tmp/singularity && ./autogen.sh && ./configure $2 && make
	else	
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make
	fi	
	;;
	"install")	
# Install Singularity from Github
	cd /tmp && git clone http://www.github.com/singularityware/singularity 
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root."
	exit 1
	else	
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
	echo "Singularity successfully installed"
	fi
	;;
	"update")
# Update Singularity from Github
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root."
	exit 1
	else
		if [ $2 ];
		then
		remove $2
		else
		remove /usr/local
		fi
	cd /tmp && git clone http://www.github.com/singularityware/singularity 
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
	echo "Singularity successfully installed"
	fi
	;;
	"install-devel")	
# Install Singularity-Development branch from Github
	cd /tmp && git clone -b development http://www.github.com/singularityware/singularity 
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root."
	exit 1
	else	
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
	echo "Singularity successfully installed"
	fi	
	;;
	"update-devel")
# Update Singularity-Development branch from Github
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root."
	exit 1
	else
		if [ $2 ];
		then
		remove $2
		else
		remove /usr/local
		fi
	cd /tmp && git clone -b development http://www.github.com/singularityware/singularity
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
	echo "Singularity successfully installed"
	fi
	;;
	"all")
# All setup, build, and install [sudo]
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root."
	exit 1
	else	
	setup
	cd /tmp && git clone http://www.github.com/singularityware/singularity 
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install
	echo "Singularity successfully installed"
	fi
	;;
	"test")
	remove /usr/local	
	;;

esac
done
