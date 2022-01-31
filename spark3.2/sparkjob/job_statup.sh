#!/bin/bash -ex


./script/apply.sh sparkdemo spark
sleep 600
#python test.py
./script/destroy.sh sparkdemo spark

# unitl we finalize ...
while :
do
	echo "Press [CTRL+C] to stop.."
	sleep 5
done
