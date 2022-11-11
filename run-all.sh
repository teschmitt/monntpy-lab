#!/bin/bash


num_runs=10
#if [ "$#" -ge 2 ]; then
    num_runs=$1
#fi


#echo "Run performance and network-simulation tests with moNNT.py and dtnd"

cd performance
# ./run.sh --run-mode experiments

cd ../net-sim
scenarios=$(ls -d eval/*)
echo
echo
echo "Network Simulation Evaluation ---------------------------------------------------"
echo "Running scenarios:"
for scen in $scenarios; do
	echo "  - $scen"
done
echo
for scen in $scenarios; do
	echo "Running scenario $scen"
	for (( i=0; i<$num_runs; i++ )); do
	    echo "  -> Running experiment $(($i + 1)) in series of $num_runs"
	    ./clab "$scen" > /dev/null 2>&1
	    echo "      -> finished run"
	done
done


cd ..
nohup poetry run jupyter-lab EvalResults.ipynb > /dev/null 2>&1
