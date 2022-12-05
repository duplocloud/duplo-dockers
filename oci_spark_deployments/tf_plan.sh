
me=`basename "$0"`
export logfile="../$me.log"
str="START `date` $me 1.spark_cluster_slave_count='$1' 2.spark_notebook_count='$2' 3.spark_job_name='$3' 4.docker_version='$4'============"
echo $str
echo "" >> $logfile
echo $str >> $logfile


echo " source ../env.sh  $1 $2 $3 $4"
source ../duplo_env.sh
source ./env.sh  $1 $2 $3 $4

cd base

echo "$me  version=${docker_version}"
echo "$me  prefix=${IMAGE_PREFIX}"
echo "$me  spark=${IMAGE_SPARK}"
echo "$me  notebook=${IMAGE_SPARK_NOTEBOOK}"
echo "$me  livy=${IMAGE_LIVY}"
echo "$me  spark-job=${IMAGE_JOB}"

log_docker_versions $versionlogfile  $me

#
cd ../spark-job/tf
./scripts/plan.sh $tenant_name spark

cd ../
export SPARK_MASTER_IP=`cat ./build/oci-sparkmaster-ip`
echo "====== SPARK_MASTER_IP=$SPARK_MASTER_IP  ======"

#env

str="END `date` $me ARGS 1.spark_cluster_slave_count='$1' 2.spark_notebook_count='$2' 3.spark_job_name='$3' 4.docker_version='$4'============"
echo $str
echo $str >> $logfile


#sleep 360
