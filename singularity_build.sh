#!/bin/bash
# Singularity Builder
# Copyright (c) 2017, Vanessa Sochat - Eduardo Arango. All rights reserved.
# Singularity: Application containers for Linux http://singularityware.github.io

Shelp (){
echo " "
echo "Singularity Build: build, install, and update Singularity software. 
Support for Debian/Ubuntu, Centos/Fedora

USAGE: ./singularity_builder.sh <command> [options] ...

COMMANDS:
    clean	clean Singularity installations
    all         setup, build, install [sudo]
    setup       install dependencies for your distribution [sudo]
    build       clone, configure and make the installation, with optional --prefix and --sysconfdir
    install     make, and make install [sudo]
    update      update the installation [sudo]
<<<<<<< HEAD
    test      	make test


=======
    test	make test
>>>>>>> 5cf6fc0b8420837e77e1533876443d42bf48b2d8

OPTIONS
    --prefix/-p  install to specified prefix.
    --devel/-d   do specified commands for development version
    --sysconfdir specify system config directory for singularity.conf

Examples:

    # Install dependencies, setup, build + install
    sudo ./singularity_build.sh all

    # Build and make, specify install to /my/path
    sudo ./singularity_build.sh build --prefix /my/path
 
    # If you already have the needed dependencies, just install
    sudo ./singularity_build.sh install

    # Update to the latest release
    sudo ./singularity_build.sh update

    # Clean Singularity installations from /my/path
    sudo ./singularity_build.sh clean --prefix /my/path

Singularity: Application containers for Linux
For additional help, see http://singularityware.github.io"
}

if [ "$#" -lt 1 ]; then
    Shelp
    exit 0
fi

setup () {
    
    ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
    if [ -f /etc/debian_version ]; then
        apt-get -y update &&
        apt-get install -y apt-utils &&
        apt-get install -y git wget \
                           build-essential \
                           libtool \
                           autotools-dev \
                           automake \
                           autoconf \
                           debootstrap \
                           yum \
                           python3-pip 

    elif [ -f /etc/redhat-release ]; then
        rhdist=$(cat /etc/redhat-release | awk '{print $1;}')
        case "$rhdist" in
        
            "CentOS")
                yum -y update &&
                yum -y group install 'Development Tools' &&
                yum -y install git wget \
                               libtool \
                               automake make \
                               autoconf \
                               debootstrap \
                               python3-pip
                ;;
        
             "Fedora")
                dnf -y update &&
                dnf -y group install 'Development Tools' &&
                dnf -y install git wget \
                               libtool \
                               automake \
                               autoconf \
                               debootstrap \
                               python3-pip
                ;;
              esac
    fi
    echo "Successfully installed dependencies for Singularity"
}

Sremove () {

    if [ -z 'whereis singularity | sed -e 's/singularity://g'' ]; then
        echo "No Singularity Installations found."
    else
        SINGULARITY_INSTALL_PREFIX="$BUILDER_INSTALL_PREFIX"
        echo "Found and clean singularity at " $SINGULARITY_INSTALL_PREFIX      
        rm -rf $SINGULARITY_INSTALL_PREFIX/libexec/singularity
        rm -rf $SINGULARITY_INSTALL_PREFIX/etc/singularity
        rm -rf $SINGULARITY_INSTALL_PREFIX/include/singularity
        rm -rf $SINGULARITY_INSTALL_PREFIX/lib/singularity
        rm -rf $SINGULARITY_INSTALL_PREFIX/var/lib/singularity/
        rm $SINGULARITY_INSTALL_PREFIX/bin/singularity
        rm $SINGULARITY_INSTALL_PREFIX/bin/run-singularity
        rm $SINGULARITY_INSTALL_PREFIX/etc/bash_completion.d/singularity 
    fi
}

Sclone () {
    if [ "$BUILDER_DEVELOPMENT" = "True" ]; then 
        cd /tmp && git clone -b development https://github.com/singularityware/singularity.git 
        echo "Cloned development branch of singularity to $PWD"
    else    
        cd /tmp && git clone https://github.com/singularityware/singularity.git
        echo "Cloned master branch of singularity to $PWD"
    fi
}

Smake () {

    if [ -z ${BUILDER_SYSCONFIG_DIR+x} ]; then 
        cd /tmp/singularity && ./autogen.sh && ./configure --prefix=$BUILDER_INSTALL_PREFIX && make 
    else 
        cd /tmp/singularity && ./autogen.sh && ./configure \
                            --prefix=$BUILDER_INSTALL_PREFIX 
                            --sysconfdir=$BUILDER_SYSCONFIG_DIR && make  
    fi
    echo "Singularity is configured at /tmp/singularity and will install to $BUILDER_INSTALL_PREFIX"
}

Smake_test () {
            if [ "$(id -u)" != "0" ]; then
                echo "Please run as root (sudo)"
                exit 1
            else
        	cd /tmp && wget "https://www.dwheeler.com/flawfinder/flawfinder-1.31.tar.gz" 
		cd flawfinder-1.31 && make prefix=/usr install
            fi
	    cd /tmp/singularity && make test
}

Sinstall () { 
    Smake && make install
	SINGULARITY_VERSION=`singularity --version`
	echo "Successfully installed  Singularity $SINGULARITY_VERSION"
}

# Options
BUILDER_INSTALL_PREFIX=/usr/local
BUILDER_DEVELOPMENT=False

# Step 1: Collect input arguments

while true; do
    case ${1:-} in

        -h|--help|help)
            Shelp
            exit 0
        ;;

        "clean")
            BUILDER_CLEAN="True"    
            shift
        ;;    

        "setup")

            if [ "$(id -u)" != "0" ]; then
                echo "Please run as root (sudo)"
                exit 1
            else
                BUILDER_RUN_SETUP="True"
            fi
            shift
        ;;

        "build")
            BUILDER_CLONE="True"
	    BUILDER_RUN_BUILD="True"    
            shift
        ;;
<<<<<<< HEAD
        "test")
   
            shift
        ;;
    
=======

        "test")
            BUILDER_TEST="True"
            shift
        ;;

>>>>>>> 5cf6fc0b8420837e77e1533876443d42bf48b2d8
        -d|--dev|--devel|dev|devel)
            BUILDER_DEVELOPMENT="True"
            export BUILDER_DEVELOPMENT
            shift
         ;;

        --sysconfdir)
            shift
            BUILDER_SYSCONFIG_DIR="${1:-}"
            export BUILDER_SYSCONFIG_DIR
            shift
         ;;

        -p|--prefix|prefix)
            shift
            BUILDER_INSTALL_PREFIX="${1:-}"
            export BUILDER_INSTALL_PREFIX
            shift
         ;;

        "install")    
            shift
            if [ "$(id -u)" != "0" ]; then
                echo "Please run as root (sudo)."
                exit 1
            else
                BUILDER_RUN_INSTALL=True
            fi
         ;;


        "update")
            shift
            if [ "$(id -u)" != "0" ]; then
                echo "Please run as root (sudo)."
                exit 1
             else
                 BUILDER_CLONE=True
                 BUILDER_REMOVE=True
                 BUILDER_RUN_UPDATE=True
             fi
         ;;
        
        "all")
             shift
             if [ "$(id -u)" != "0" ]; then
                 echo "Please run as root (sudo)."
                 exit 1
             else    
                 BUILDER_RUN_SETUP=True
                 BUILDER_CLONE=True
                 BUILDER_RUN_INSTALL=True
             fi
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

if [ -n "${BUILDER_CLEAN:-}" ]; then
    Sremove
fi

if [ -n "${BUILDER_RUN_SETUP:-}" ]; then
    setup
fi

if [ -n "${BUILDER_CLONE:-}" ]; then
    Sclone
fi

if [ -n "${BUILDER_RUN_BUILD:-}" ]; then
    Smake
fi

if [ -n "${BUILDER_TEST:-}" ]; then
    Smake_test
fi

if [ -n "${BUILDER_RUN_INSTALL:-}" ]; then
	if [ -f /tmp/singularity ]; then    
		Sinstall
		else
		Sclone
		Sinstall
		fi
fi

if [ -n "${BUILDER_RUN_UPDATE:-}" ]; then
    Sremove
    Sclone
    Sinstall
    echo "Finished update of Singularity"
    exit 0
fi

if [ -n "${BUILDER_RUN_ALL:-}" ]; then
    setup
    Sclone
    Sinstall
    echo "Finished setup, clone, and build, and install for Singularity"
    exit 0
fi

if [ -n "${BUILDER_TEST:-}" ]; then
    Smake_test
fi

exit 0
# END OF FILE!
