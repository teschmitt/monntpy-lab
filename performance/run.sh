#!/bin/bash

docker run \
    --rm \
    --tty \
    --interactive \
    --volume $(pwd):/shared \
    --name monntpy-bench \
    monntpy-bench