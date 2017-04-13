#!/bin/bash
#
# Copyright (c) 2017, Vanessa Sochat. All rights reserved.
# Singularity Builder Testing


if [ ! -d "./tests/" ]; then
    /bin/echo "ERROR: Could not locate singularity builder test directory"
    exit 1
fi

if ! cd tests; then
    /bin/echo "ERROR: Could not change into the Singularity builder test directory"
    exit 1
fi

if [ -n "$1" ]; then
    for i in $@; do
        test=`basename "$i"`
        if [ -f "$test" ]; then
            if ! /bin/sh "$test"; then
                /bin/echo "ERROR: Failed running test: $test"
                exit 1
            fi
        else
            echo "ERROR: Could not find test: '$test'"
            exit 1
        fi
    done
else
    for test in *.sh; do
        if [ -f "$test" ]; then
            if ! /bin/sh "$test"; then
                /bin/echo "ERROR: Failed running test: $test"
                exit 1
            fi
        fi
    done
fi

echo
echo "All tests passed"
