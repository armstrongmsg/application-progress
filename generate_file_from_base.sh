#!/bin/bash

INPUT_FILE=$1
OUTPUT_FILE=$2
OUTPUT_FILE_SIZE=$3
INPUT_FILE_SIZE="`ls -l $INPUT_FILE | awk '{ print $5 }'`"

for i in `seq 1 $(( $OUTPUT_FILE_SIZE/$INPUT_FILE_SIZE ))`
do
	cat $INPUT_FILE >> $OUTPUT_FILE
done
