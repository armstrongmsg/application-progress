#!/bin/bash

CAPS="25 50 75 100"
REPEATS=1
VM_NAME="ubuntu-spark"
VM_IP="192.168.122.94"
SPARK_HOME="/home/ubuntu/spark-2.1.0-bin-hadoop2.7"
APPLICATION="Match"
OUTPUT_FILE="experiment-completion.csv"

# Pi Parameters
PI_CLASS="org.apache.spark.examples.SparkPi"
PI_JAR="$SPARK_HOME/examples/jars/spark-examples_2.11-2.1.0.jar"
PI_N=100

# Entity Matching Parameters
ENTITY_MATCH_CLASS="StreamlinedMetablockingAvoidRedundancy.StreamlinedMetablockingWNPLessComparison2"
ENTITY_MATCH_JAR="/home/ubuntu/RunLSD/StreamlinedMetablockingAvoidRedundancy.jar"
ENTITY_MATCH_INPUTFILE="/home/ubuntu/RunLSD/edbp.txt"
ENTITY_MATCH_OUTPUTFILE="$SPARK_HOME/output"
ENTITY_MATCH_PAR1=15
ENTITY_MATCH_PAR2=1190733
ENTITY_MATCH_PAR3=2164040
ENTITY_MATCH_FILTER_PARAMETER=0.000000000001

if [ $APPLICATION = "Match" ]
then
	CLASS=$ENTITY_MATCH_CLASS
	JAR=$ENTITY_MATCH_JAR
	PARAMETERS="$ENTITY_MATCH_INPUTFILE $ENTITY_MATCH_OUTPUTFILE $ENTITY_MATCH_PAR1 $ENTITY_MATCH_PAR2 $ENTITY_MATCH_PAR3 $ENTITY_MATCH_FILTER_PARAMETER"
elif [ $APPLICATION = "Pi" ]
then
	CLASS="$PI_CLASS"
	JAR=$PI_JAR
	PARAMETERS="$PI_N"
fi

echo "Running application: $APPLICATION"
echo "Parameters: $PARAMETERS"

mv $OUTPUT_FILE $OUTPUT_FILE.bak
echo "timestamp,completion,stage,cap" >> $OUTPUT_FILE

for cap in $CAPS
do		
	echo "---------------------"
        echo "Using cap: $cap"
	echo "---------------------"
	virsh schedinfo $VM_NAME --set vcpu_quota=$(( $cap * 1000 )) > /dev/null

	for rep in `seq 1 $REPEATS`
	do
                echo "Removing output directories"
                ssh ubuntu@$VM_IP rm -rf $SPARK_HOME/output
                ssh ubuntu@$VM_IP rm -rf $SPARK_HOME/outputReport	

                echo "Starting application"
                ssh ubuntu@$VM_IP $SPARK_HOME/bin/spark-submit --master spark://ubuntu:7077 --class $CLASS $JAR $PARAMETERS 2> spark_log.txt &

                echo "Starting progress monitor"
                python progress-collect.py > completion.csv

                echo "Adding cap to result file"
		awk -v d="$cap" -F"," 'BEGIN { OFS = "," } {$4=d; print}' completion.csv >> $OUTPUT_FILE
	done
done
