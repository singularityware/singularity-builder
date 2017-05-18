#!/bin/bash
#
# Copyright (c) 2017, Eduardo Arango. All rights reserved.
# Singularity Builder Testing

. ./functions

test_init "Testing builder with ubuntu"


ALL_COMMANDS="all setup build install update"

stest 0 docker run --rm --name=ubuntu ashael/ubuntu-builder
stest 0 docker run --rm --name=ubuntu ashael/ubuntu-builder --help

for i in $ALL_COMMANDS; do
    echo
    echo "Testing command ./singularity_build.sh: '$i'"
    stest 0 docker run --rm --name=ubuntu ashael/ubuntu-builder "$i"
done

for i in $ALL_COMMANDS; do
    echo
    echo "Testing command ./singularity_build.sh: '$i' --devel"
    stest 0 docker run --rm --name=ubuntu ashael/ubuntu-builder "$i --devel"
done
	echo "Testing command make test for devel branch"
	stest 0 docker run --privileged --rm --name=ubuntu ashael/ubuntu-builder all test --devel

test_cleanup
#END OF FILE!
