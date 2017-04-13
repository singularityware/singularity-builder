#!/bin/bash
#
# Copyright (c) 2017, Vanessa Sochat. All rights reserved.
# Singularity Builder Testing

. ./functions

test_init "Testing builder with centos"


ALL_COMMANDS="all setup build install update"

stest 0 docker run vanessa/centos-builder
stest 0 docker run vanessa/centos-builder --help

for i in $ALL_COMMANDS; do
    echo
    echo "Testing command ./singularity_build.sh: '$i'"
    stest 0 docker run vanessa/centos-builder "$i"
done

BUILD_COMMANDS="all build install update"

for i in $BUILD_COMMANDS; do
    echo
    echo "Testing command ./singularity_build.sh: '$i' --prefix=/opt/singularity"
    stest 0 docker run vanessa/centos-builder "$i" --prefix=/opt/singularity
done

test_cleanup
