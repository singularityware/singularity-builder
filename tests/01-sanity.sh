#!/bin/bash
#
# Copyright (c) 2017, Vanessa Sochat. All rights reserved.
# Singularity Builder Testing

. ./functions

test_init "Checking environment"

stest 0 sudo true
stest 1 sudo false

test_cleanup
