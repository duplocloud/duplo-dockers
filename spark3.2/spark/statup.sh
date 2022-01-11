#!/bin/bash -ex

# 1 for node : set { "DUPLO_SPARK_NODE_TYPE"="worker", "DUPLO_PARK_MASTER_IP"="x.x.x.x"}
# 2- for master : -

master=$DUPLO_DOCKER_HOST
if [[ "x$DUPLO_SPARK_MASTER_IP" != "x" ]]; then
    master=$DUPLO_SPARK_MASTER_IP
fi


############################## enable max memory option : default : Xms1024M Xmx4096M ########################
#todo: may be not needed
totalk=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
max_mem=$(( ${totalk}*80/100 ))
min_mem=$(( ${totalk}*40/100 ))
echo "totalk=${totalk}K 80% max_mem=${max_mem}K 40% min_mem=${min_mem}K"
xms="${min_mem}K"
xmx="${max_mem}K"

echo "SPARK_OPTS ${SPARK_OPTS} before "
export spark_master_ip=$master
export SPARK_OPTS="--driver-java-options=-Xms${xms} --driver-java-options=-Xmx${xmx} --driver-java-options=-Dlog4j.logLevel=info"
echo "spark_master_ip = ${master} xms = ${xms} xms = ${xmx} ${SPARK_OPTS}"
echo "SPARK_OPTS ${SPARK_OPTS} after "
############################## enable max memory option : default : Xms1024M Xmx4096M ########################

cd /opt/spark/bin
if [[ "x$DUPLO_SPARK_NODE_TYPE" != "x" ]]; then
    if [ "$DUPLO_SPARK_NODE_TYPE" = "worker" ]
    then
        cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.worker.Worker \
           --webui-port $SPARK_WORKER_WEBUI_PORT spark://$master:7077 >> $SPARK_WORKER_LOG
    else
      cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.master.Master \
            -h $master --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> $SPARK_MASTER_LOG
    fi
else
      cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.master.Master \
            -h $master --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> $SPARK_MASTER_LOG
fi



while :
do
	echo "Press [CTRL+C] to stop.."
	sleep 5
done
