#!/bin/bash -ex

bash /create_oci_profile.sh

# 1 for node : set { "DUPLO_SPARK_NODE_TYPE":"worker", "DUPLO_PARK_MASTER_IP":"x.x.x.x"}
# 2- for master : -

master=$DUPLO_DOCKER_HOST
if [[ "x$DUPLO_SPARK_MASTER_IP" != "x" ]]; then
    master=$DUPLO_SPARK_MASTER_IP
fi

if [[ "x$LOCAL_DOCKER_HOST" != "x" ]]; then
    echo "using local host mode ============== "
else
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
fi

export spark_master=${master}
echo "spark.master spark://${master}:7077" | sudo tee -a /opt/spark/conf/spark-defaults.conf

mkdir -p /home/centos/work
cd /home/centos/work
cp /home/centos/*.ipynb /home/centos/work/
cp -r /home/centos/mobility_eval /home/centos/work/mobility_eval
cp -r /home/centos/notebooks/ /home/centos/work/notebooks

export PATH=$PATH:~/.local/bin
jupyter notebook
#python3 -m notebook


# unitl we finalize ...
#while :
#do
#	echo "Press [CTRL+C] to stop.."
#	sleep 5
#done
