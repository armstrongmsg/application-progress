#!/bin/bash

NUMBER_OF_WORDS=$1
TARGET_SIZE=$2
OUTPUT_FILE=$3
WORDS=""

touch $OUTPUT_FILE
shuf -n $NUMBER_OF_WORDS "english_words.txt" > "chosen_words.txt"

OUTPUT_FILE_SIZE="`ls -l $OUTPUT_FILE | awk '{ print $5 }'`"

while [ $OUTPUT_FILE_SIZE -le $TARGET_SIZE ]
do
	WORD="`shuf -n 1 "chosen_words.txt"`"
	echo $WORD >> $OUTPUT_FILE
	OUTPUT_FILE_SIZE="`ls -l $OUTPUT_FILE | awk '{ print $5 }'`"
done
