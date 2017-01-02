#!/bin/sh
sudo apt-get update
sudo apt-get -y install git
sudo apt-get install -y build-essential libtool autotools-dev automake autoconf
sudo apt-get install -y python3-pip
cd /tmp && git clone http://www.github.com/singularityware/singularity
cd singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install
export SINGULARITY_VERSION=$(singularity --version)
sudo pip3 install --upgrade pip
sudo pip3 install --upgrade google-api-python-client
sudo pip3 install --upgrade google
sudo pip3 install oauth2client==3.0.0
sudo pip3 install gitpython
sudo pip3 install singularity
