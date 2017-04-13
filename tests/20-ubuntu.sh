#!/bin/bash
#
# Copyright (c) 2017, Vanessa Sochat. All rights reserved.
# Singularity Builder Testing

. ./functions

test_init "Testing builder with ubuntu"


ALL_COMMANDS="all setup build install update"

stest 0 docker run vanessa/ubuntu-builder
stest 0 docker run vanessa/ubuntu-builder --help

for i in $ALL_COMMANDS; do
    echo
    echo "Testing command ./singularity_build.sh: '$i'"
    stest 0 docker run vanessa/ubuntu-builder "$i"
done

/bin/echo
/bin/echo "Testing error on bad commands"


stest 1 docker run vanessa/ubuntu-builder bogus
stest 1 docker run vanessa/ubuntu-builder --help bogus

test_cleanup
