#!/bin/bash
#Singularity Builder
#Singularity: Application containers for Linux http://singularity.lbl.gov/

Shelp (){
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

  # Build + optional prefix
  sudo ./singularity_build.sh build --prefix=/my/path
 
  # If you already have the needed dependencies, just install
  sudo ./singularity_build.sh install

  # Update to the latest release
  sudo ./singularity_build.sh update

Singularity: Application containers for Linux
For additional help, see http://singularity.lbl.gov/"
exit 1
}
if [ "$#" -lt 1 ];
then
Shelp
fi

setup () {
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
	if [ -f /etc/debian_version ]; then
    	apt-get -y update > /tmp/.install-log
	apt-get install -y apt-utils >> /tmp/.install-log
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
        	yum -y update > /tmp/.install-log
		yum -y group install 'Development Tools'
		yum -y install git \
                   	libtool \
                   	automake make \
                   	autoconf \
                   	debootstrap \
                   	python3-pip >> /tmp/.install-log
			;;
		"Fedora")
        	dnf -y update > /tmp/.install-log
		dnf -y group install 'Development Tools'
		dnf -y install git \
                   	libtool \
                   	automake \
                   	autoconf \
                   	debootstrap \
                   	python3-pip >> /tmp/.install-log
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
}

Sclone () {
	if [ "$1" == "devel" ]; 
	then 
	cd /tmp && git clone -b development http://www.github.com/singularityware/singularity 
	else	
	cd /tmp && git clone http://www.github.com/singularityware/singularity
	fi
}
Smake () {
	if [ $1 ];
	then
	cd /tmp/singularity && ./autogen.sh && ./configure $1 && make 
	else 
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make 
	fi
}

Sinstall () { 
	if [ $1 ];
	then
	cd /tmp/singularity && ./autogen.sh && ./configure $1 && make && make install 
	else 
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && make install 
	fi
}

while true; do
case ${1:-} in
	-h|--help|help)
	Shelp
	exit
	;;
# Install dependencies for your distribution [sudo]
	"setup")
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root.[sudo]"
	exit 1
	else
	setup
	fi
	shift
	;;
	"build")
# Build configure and make the installation, with optional --prefix 
	Sclone	
	shift
	if [ $1 ]; then
	Smake $1
	else
	Smake
	fi
	;;
	"build-devel")
# Build configure and make the installation, with optional --prefix
	Sclone devel
	shift
	if [ $1 ]; then
	Smake $1
	else
	Smake
	fi
	;;
	"install")	
# Install Singularity from Github
	shift
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root.[sudo]"
	exit 1
	else
		if [ $1 ];
		then	
		Sinstall $1
		else	
		Sinstall
		fi
	singularity selftest		
	echo "Singularity successfully installed"
	fi
	exit
	;;
	"update")
# Update Singularity from Github
	shift
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root.[sudo]"
	exit 1
	else
		if [ $1 ];
		then
		remove `echo "${1//--prefix=}"`
		Sinstall $1
		else
		remove /usr/local
		Sinstall
		fi
	singularity selftest
	echo "Singularity successfully installed"
	fi
	exit
	;;
	"install-devel")	
# Install Singularity-Development branch from Github
	shift	
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root.[sudo]"
	exit 1
	else	
		if [ $1 ];
		then
		Sclone	devel
		Sinstall $1
		else
		Sclone
		Sinstall
		fi
	singularity selftest
	echo "Singularity successfully installed"
	fi
	exit
	;;
	"update-devel")
# Update Singularity-Development branch from Github
	shift	
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root.[sudo]"
	exit 1
	else
		if [ $1 ];
		then
		remove `echo "${1//--prefix=}"`
		Sclone devel
		Sinstall $1
		else
		remove /usr/local
		Sclone
		Sinstall	
		fi
	singularity selftest
	echo "Singularity successfully installed"
	fi
	exit
	;;
	"all")
# All setup, build, and install [sudo]
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root.[sudo]"
	exit 1
	else	
	setup
	Sclone
		if [ $1 ];
		then
		Sinstall $1
		else
		Sinstall
		fi
	singularity selftest
	echo "Singularity successfully installed"
	fi
	exit
	;;
	"all-devel")
# All-development branch setup, build, and install [sudo]
	shift	
	if [ "$(id -u)" != "0" ]; then
	echo "Please run as root.[sudo]"
	exit 1
	else	
	setup
	Sclone devel
		if [ $1 ];
		then
		Sinstall $1
		else
		Sinstall --prefix=/usr/local
		fi
	singularity selftest
	echo "Singularity successfully installed"
	fi
	exit
	;;
        -*)
            echo "Unknown option: ${1:-}"
            exit 1
        ;;
	*)
		break
	;;
esac
done
