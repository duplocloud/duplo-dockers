
#!/bin/bash -ex

bash /create_oci_profile.sh

# 1 for slave : set { "DUPLO_SPARK_NODE_TYPE"="worker", "DUPLO_PARK_MASTER_IP"="x.x.x.x"}
# 2- for master :  not required

# todo: query host and calculate NUMBER_OF_CORES=${total_cpus - 1}

NUMBER_OF_CORES=${NUMBER_OF_CORES:-3}
RAM_SIZE=${RAM_SIZE:-2G}

master=$DUPLO_DOCKER_HOST
if [[ "x$DUPLO_SPARK_MASTER_IP" != "x" ]]; then
    master=$DUPLO_SPARK_MASTER_IP
fi

if [[ "x$LOCAL_DOCKER_HOST" != "x" ]]; then
    echo "using local host mode ============== "
else
    ############################## enable max memory option : default : Xms1024M Xmx4096M ########################
    #todo: may be not needed
    NUMBER_OF_CORES=$( cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)
    #its in KB
    RAM_SIZE_TOTAL=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
    RAM_SIZE=$(( ${RAM_SIZE_TOTAL}*1/1000000 - 1))

    echo "NUMBER_OF_CORES ${NUMBER_OF_CORES}  RAM_SIZE_TOTAL ${RAM_SIZE_TOTAL}  RAM_SIZE ${RAM_SIZE}   "

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
fi


mkdir -p $SPARK_LOG_DIR
touch $SPARK_WORKER_LOG
touch $SPARK_MASTER_LOG

echo "=========DUPLO_SPARK_NODE_TYPE ================ starting $DUPLO_SPARK_NODE_TYPE $master  ==============================="
cd /opt/spark/bin

export spark_master=${master}

if [ "$DUPLO_SPARK_NODE_TYPE" = "worker" ]
then
    echo "spark.master spark://${master}:7077" | sudo tee -a /opt/spark/conf/spark-defaults.conf
    echo " cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.worker.Worker  spark://$master:7077 -c $NUMBER_OF_CORES -m $RAM_SIZE >> $SPARK_WORKER_LOG "
    cd /opt/spark/bin && \
     ./spark-class org.apache.spark.deploy.worker.Worker \
      spark://$master:7077 -c $NUMBER_OF_CORES -m ${RAM_SIZE}G >> $SPARK_WORKER_LOG
else
    $LIVY_HOME/bin/livy-server >> /hoke/centos/livy.log &
    echo " cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.master.Master   -h $master --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> $SPARK_MASTER_LOG"
    cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.master.Master \
          -h $master --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> $SPARK_MASTER_LOG
fi
echo "========DUPLO_SPARK_NODE_TYPE ================= DONE  $DUPLO_SPARK_NODE_TYPE $master   ==============================="
