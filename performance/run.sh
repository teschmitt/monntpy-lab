#!/bin/bash

if [ -n "$1" ]; then
    # if there is a number provided, change numer of messages to that number
    num=$1
else
    num=100
fi

if [ -n "$2" ]; then
    # if there is a number provided, change numer of messages to that number
    db_path="$2"
else
    db_path="/app/moNNT.py"
fi

docker run \
    --rm \
    --tty \
    --interactive \
    --env NUM_ARTICLES=$num \
    --env DB_PATH=$db_path \
    --volume $(pwd):/shared \
    --name monntpy-bench \
    monntpy-bench