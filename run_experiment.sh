#!/bin/bash

CAPS="25 50 75 100"
REPEATS=2
VM_NAME="spark-slave"

PI_NUM_TASKS=100
OUTPUT_FILE="experiment-completion.csv"

echo "timestamp,completion,cap"

#
#
# PI
#
#
for cap in $CAPS
do		
	# set cap
	virsh schedinfo $VM_NAME --set vcpu_quota=$(( $cap * 1000 ))

	for rep in `seq 1 $REPEATS`
	do
		#run application 	
		./pi.py $PI_NUM_TASKS
		START_TIME="`cat completion.csv | awk -F"," 'NR==1 {print $1}'`"
		awk -v d="$cap" -v start_time=$START_TIME -F"," 'BEGIN { OFS = "," } {$3=d; $1=$1-start_time; print}' completion.csv >> $OUTPUT_FILE
		rm completion.csv
	done
done
