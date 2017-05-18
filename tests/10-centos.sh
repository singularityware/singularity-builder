#!/bin/bash
#
# Copyright (c) 2017, Eduardo Arango. All rights reserved.
# Singularity Builder Testing

. ./functions

test_init "Testing builder with centos"


ALL_COMMANDS="all setup build install update"

stest 0 docker run --rm --name=centos ashael/centos-builder
stest 0 docker run --rm --name=centos ashael/centos-builder --help

for i in $ALL_COMMANDS; do
    echo
    echo "Testing command ./singularity_build.sh: '$i'"
    stest 0 docker run --rm --name=centos ashael/centos-builder "$i"
done


for i in $ALL_COMMANDS; do
    echo
    echo "Testing command ./singularity_build.sh: '$i' --devel"
    stest 0 docker run --rm --name=centos ashael/centos-builder "$i --devel"
done

    stest 0 docker run --privileged --rm --name=centos ashael/centos-builder all test --devel

test_cleanup
#END OF FILE!
