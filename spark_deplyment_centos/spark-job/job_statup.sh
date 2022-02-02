#!/bin/bash -ex

./scripts/apply.sh sparkdemo spark

sleep 60

export SPARK_MASTER_IP `cat ./tf-spark-cluster/terraform/spark/eks-sparkmaster-ip`
echo $SPARK_MASTER_IP
python test.py

sleep 60

./scripts/destroy.sh sparkdemo spark

sleep 60
