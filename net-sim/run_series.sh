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
permloc="$scen/multirun-results"
mkdir -p "$permloc"
echo "  -> results will be save to $permloc"

for (( i=0; i<$total_runs; i++ )); do
    echo "  -> Running experiment $(($i + 1)) in series of $total_runs"
    ./clab "$scen" > /dev/null 2>&1
    echo "      -> finished run"

    # move all data files out to permanent location
    newest=$(ls -td "$scen/results-$1-"* | head -1)
    ts=$(echo $newest | sed "s/^.*-$1-//")

    echo "      -> copying node logs from $newest ..."
    for d in $(ls -d "$newest/n"*); do
        j=$(echo "$d" | sed -E 's|.*/n([[:digit:]]+)$|\1|')     # get number from end of dir path
        cp "$d/pidstat-n$j.csv.log" "$permloc/pidstat-n$j-$ts.csv"
        cp "$d/net-n$j.log" "$permloc/net-n$j-$ts.log"
    done
    # rm -rf "$newest"
done
