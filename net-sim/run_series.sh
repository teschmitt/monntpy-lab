#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Please provide name of scenario and number of runs"
    exit 1
fi

if [ ! -d "eval/$1" ]; then
    echo "eval/$1 does not exist, please pick valid scenario directory"
    exit 1
fi

scen="eval/$1"
total_runs=$2

echo "Running scenario $1"

for (( i=0; i<$total_runs; i++ )); do
    echo "  -> Running experiment $(($i + 1)) in series of $total_runs"
    ./clab "$scen" > /dev/null 2>&1
    echo "      -> finished run"
done
