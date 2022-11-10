#!/bin/bash

echo "Building all containers:"
cur=$(pwd)
cd performance
docker build --tag monntpy-perf .
cd ../net-sim
docker build --tag monntpy-netsim .
cd "$cur"
