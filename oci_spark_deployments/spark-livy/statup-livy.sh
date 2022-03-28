#!/bin/bash -ex

# 1 for node : set { "DUPLO_SPARK_NODE_TYPE"="worker", "DUPLO_PARK_MASTER_IP"="x.x.x.x"}
# 2- for master : -

master=$DUPLO_DOCKER_HOST
if [[ "x$DUPLO_SPARK_MASTER_IP" != "x" ]]; then
    master=$DUPLO_SPARK_MASTER_IP
fi

echo "livy.spark.master =  spark://${master}:7077" | sudo tee -a $LIVY_CONF_DIR/livy.conf

$LIVY_HOME/bin/livy-server
#
while :
do
	echo "Press [CTRL+C] to stop.."
	sleep 5
done
