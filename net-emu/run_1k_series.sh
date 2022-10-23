#!/bin/bash

permloc="eval/1k/multirun-results"
mkdir -p "$permloc"

for (( i=0; i<50; i++ )); do
	./clab eval/1k

	sudo chown -R thomas:thomas .
	
	# move all data files out to permanent location
	newest=$(ls -td eval/1k/results-1k-* | head -1)
	suffix=$(echo $newest | sed 's/^.*-1k-//')
	for j in 1 2 3; do
		mv "$newest/n$j/pidstat-n$j.csv.log" "$permloc/pidstat-n$j-$suffix.csv"
		mv "$newest/n$j/net-n$j.log" "$permloc/net-n$j-$suffix.log"
	done
	rm -rf "$newest"
done
