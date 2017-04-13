#!/bin/bash
# Singularity Builder
# Singularity: Application containers for Linux http://singularityware.github.io

Shelp (){

echo "Singularity Builder: build, install, and update Singularity software. 
Support for Debian/Ubuntu, Centos/Fedora

USAGE: ./singularity_builder.sh <command> [options] ...

COMMANDS:
    all         setup, build, install [sudo]
    setup       install dependencies for your distribution [sudo]
    build       configure and make the installation, with optional --prefix and --sysconfdir
    install     make, and make install [sudo]
    update      update the installation [sudo]


OPTIONS
    --prefix/-p  install to specified prefix.
    --devel/-d   do specified commands for development version
    --sysconfdir specify system config directory fot singularity.conf

Examples:

    # Install dependencies, setup, build + install
    sudo ./singularity_build.sh all

    # Build and make, specify install to /my/path
    sudo ./singularity_build.sh build --prefix=/my/path
 
    # If you already have the needed dependencies, just install
    sudo ./singularity_build.sh install

    # Update to the latest release
    sudo ./singularity_build.sh update

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
        apt-get install -y git \
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
                yum -y install git \
                               libtool \
                               automake make \
                               autoconf \
                               debootstrap \
                               python3-pip
                ;;
        
             "Fedora")
                dnf -y update &&
                dnf -y group install 'Development Tools' &&
                dnf -y install git \
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

    if ! SINGULARITY_PATH=`singularity_which "singularity"`; then
        echo "No Singularity Installations found."
    else
        SINGULARITY_INSTALL_PREFIX="${SINGULARITY_PATH/"/bin/singularity"/}"
        echo "Found singularity at " $SINGULARITY_INSTALL_PREFIX      
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

Sinstall () { 
    Smake && make install 
}

# Commands
BUILDER_RUN_SETUP=False             # setup
BUILDER_RUN_BUILD=False             # Sclone
BUILDER_CLONE=False                 # Sclone Smake
BUILDER_RUN_UPDATE=False            # remove Sinstall
BUILDER_RUN_INSTALL=False            # remove Sinstall
BUILDER_RUN_ALL=False               # remove S

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
    
        "setup")

            if [ "$(id -u)" != "0" ]; then
                echo "Please run as root (sudo)"
                exit 1
            else
                BUILDER_RUN_SETUP=True
            fi
            shift
        ;;
    

        "build")
            BUILDER_CLONE=True    
            shift
        ;;

       
        -d|--dev|--devel|dev|devel)
            export BUILDER_DEVELOPMENT=True
            shift
         ;;

        --sysconfdir)
            shift
            export BUILDER_SYSCONFIG_DIR="${1:-}"
            shift
         ;;

        -p|--prefix|prefix)
            shift
            export BUILDER_INSTALL_PREFIX="${1:-}"
            shift
         ;;

        "install")    
            shift
            if [ "$(id -u)" != "0" ]; then
                echo "Please run as root (sudo)."
                exit 1
            else
                BUILDER_RUN_INSTAll=True
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

if [ $BUILDER_CLONE = "True" ]; then
    Sclone
fi

# Install and build are redundant
if [ $BUILDER_RUN_INSTALL = "True" ]; then
    BUILDER_RUN_BUILD=False
fi


if [ $BUILDER_RUN_UPDATE = "True" ]; then
    Sremove
    Sclone
    Sinstall
    echo "Finished update of Singularity"
    exit 0
fi


if [ $BUILDER_RUN_ALL = "True" ]; then
    setup
    Sclone
    Sinstall
    echo "Finished setup, clone, and build, and install for Singularity"
    exit 0
fi

if [ $BUILDER_RUN_SETUP = "True" ]; then
    setup
fi

if [ $BUILDER_RUN_BUILD = "True" ]; then
    Smake
fi

if [ $BUILDER_RUN_INSTALL = "True" ]; then
    Sinstall
fi

exit 0
