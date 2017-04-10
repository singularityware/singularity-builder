#Singularity Builder
#Singularity: Application containers for Linux http://singularity.lbl.gov/
# For Build + install do
# sudo ./singularity_build.sh build install
# If you have all that's needed simply go for
# sudo ./singularity_build.sh install
# To Update do
# sudo ./singularity_build.sh update
#!/Bin/Bash

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
		yum -y install git \
                   	build-essential \
                   	libtool \
                   	autotools-dev \
                   	automake \
                   	autoconf \
                   	debootstrap \
                   	python3-pip >> /tmp/.install-log
			;;
		"Fedora")
        	dnf update > /tmp/.install-log
		dnf -y install git \
                   	build-essential \
                   	libtool \
                   	autotools-dev \
                   	automake \
                   	autoconf \
                   	debootstrap \
                   	python3-pip >> /tmp/.install-log
			;;
	esac
	fi
	;;
	"install")	
# Install Singularity from Github
	cd /tmp && git clone http://www.github.com/singularityware/singularity 
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install
	;;
	"update")
# Update Singularity from Github
	sed -e 's/singularity://g' singularitybins.out | rm -rf
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install
	;;
	"install-devel")	
# Install Singularity-Development branch from Github
	cd /tmp && git clone http://www.github.com/singularityware/singularity 
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install
	;;
	"update-devel")
# Update Singularity-Development branch from Github
	sed -e 's/singularity://g' singularitybins.out | rm -rf
	cd /tmp/singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install
	;;
esac
done
