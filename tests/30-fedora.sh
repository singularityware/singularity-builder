#!/bin/bash
#
# Copyright (c) 2017, Eduardo Arango. All rights reserved.
# Singularity Builder Testing

. ./functions

test_init "Testing builder with fedora"


ALL_COMMANDS="all setup build install update"

stest 0 docker run --rm --name=fedora ashael/fedora-builder
stest 0 docker run --rm --name=fedora ashael/fedora-builder --help

for i in $ALL_COMMANDS; do
    echo
    echo "Testing command ./singularity_build.sh: '$i'"
    stest 0 docker run ashael/fedora-builder "$i"
done

for i in $ALL_COMMANDS; do
    echo
    echo "Testing command ./singularity_build.sh: '$i'"
    stest 0 docker run ashael/fedora-builder "$i --devel"
done

	echo ""
	stest 0 docker run --privileged --rm --name=fedora ashael/fedora-builder all test --devel
	
test_cleanup
#END OF FILE!
