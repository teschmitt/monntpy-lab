#!/bin/bash

if [ -n "$1" ]; then
    # if there is a number provided, change numer of messages to that number
    num=$1
else
    num=100
fi

docker run \
    --rm \
    --tty \
    --interactive \
    --env NUM_ARTICLES=$num \
    --volume $(pwd):/shared \
    --name monntpy-bench \
    monntpy-bench