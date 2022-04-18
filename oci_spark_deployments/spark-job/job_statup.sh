#!/bin/bash -ex

bash /create_oci_profile.sh

./scripts/apply.sh sparkdemo spark

export SPARK_HOME=/opt/spark
export SPARK_MASTER_IP=`cat ./build/eks-sparkmaster-ip`
export SPARK_LIVY_IP=`cat ./build/eks-sparklivy-ip`

echo "SPARK_MASTER_IP=$SPARK_MASTER_IP SPARK_HOME=$SPARK_HOME"

echo "sleep 180"
sleep 180


echo "============ running job START===================="
#python test.py
/opt/spark/bin/spark-submit --master "spark://${SPARK_MASTER_IP}:7077" /opt/spark/examples/src/main/python/pi.py
/opt/spark/bin/spark-submit --master "spark://${SPARK_MASTER_IP}:7077" test.py
echo "============ running job END===================="

echo "sleep 120"
sleep 120

echo "/scripts/destroy.sh sparkdemo spark"
./scripts/destroy.sh sparkdemo spark
echo "sleep 240 "
sleep 240
