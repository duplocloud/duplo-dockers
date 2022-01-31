#!/bin/bash -ex


./script/apply.sh sparkdemo spark
sleep 600
#python test.py
./script/destroy.sh sparkdemo spark
sleep 600
