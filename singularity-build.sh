#!/bin/sh

sudo apt-get update
sudo apt-get -y install git
git clone http://www.github.com/singularityware/singularity
cd singularity && ./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install
cd $HOME && git clone https://github.com/singularityware/singularity-python
cd singularity-python && ${HOME}/anaconda2/bin/python setup.py sdist && ${HOME}/anaconda2/bin/python setup.py install
echo "export PATH=${HOME}/anaconda2/bin:$PATH" >> ~/.bashrc
which singularity
