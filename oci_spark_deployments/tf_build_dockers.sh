
me=`basename "$0"`
export logfile="../$me.log"
str="START `date` $me 1.spark_cluster_slave_count='$1' 2.spark_notebook_count='$2' 3.spark_job_name='$3' 4.docker_version='$4'============"
echo $str
echo "" >> $logfile
echo $str >> $logfile


echo " source ../env.sh  $1 $2 $3 $4"
source ../duplo_env.sh
source ./env.sh  $1 $2 $3 $4

echo "$me before_build version=${docker_version}"
echo "$me before_build prefix=${IMAGE_PREFIX}"
echo "$me before_build spark=${IMAGE_SPARK}"
echo "$me before_build notebook=${IMAGE_SPARK_NOTEBOOK}"
echo "$me before_build livy=${IMAGE_LIVY}"
echo "$me before_build spark-job=${IMAGE_JOB}"





log_docker_versions $versionlogfile before_build $me
log_docker_versions $logfile before_build $me

cd base

#1
cd ../base
parent_image=$IMAGE_OS
build_image=$IMAGE_BASE
str_build="docker build  --build-arg BASE_CONTAINER=$parent_image  -f Dockerfile -t $build_image ."
echo "======  $str_build START======"
$str_build
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "======  $str_build . ERROR======"
    exit $retVal
fi
echo "======  $str_build . END======\n\n\n"
sleep 5


#2
cd ../spark;
parent_image=$IMAGE_BASE
build_image=$IMAGE_SPARK
str_build="docker build  --build-arg BASE_CONTAINER=$parent_image  -f Dockerfile -t $build_image ."
echo "======  $str_build START======"
$str_build
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "======  $str_build . ERROR======"
    exit $retVal
fi
echo "======  $str_build . END======\n\n\n"
sleep 5


#3
cd ../spark-notebook
parent_image=$IMAGE_SPARK
build_image=$IMAGE_SPARK_NOTEBOOK
str_build="docker build  --build-arg BASE_CONTAINER=$parent_image  -f Dockerfile -t $build_image ."
echo "======  $str_build START======"
$str_build
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "======  $str_build . ERROR======"
    exit $retVal
fi
echo "======  $str_build . END======\n\n\n"
sleep 5


#5
cd ../spark-job
parent_image=$IMAGE_SPARK
build_image=$IMAGE_JOB
str_build="docker build  --build-arg BASE_CONTAINER=$parent_image  -f Dockerfile -t $build_image ."
echo "======  $str_build START======"
$str_build
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "======  $str_build . ERROR======"
    exit $retVal
fi
echo "======  $str_build . END======\n\n\n"
sleep 5


#

echo "$me after_build version=${docker_version}"
echo "$me after_build prefix=${IMAGE_PREFIX}"
echo "$me after_build spark=${IMAGE_SPARK}"
echo "$me after_build notebook=${IMAGE_SPARK_NOTEBOOK}"
echo "$me after_build livy=${IMAGE_LIVY}"
echo "$me after_build spark-job=${IMAGE_JOB}"


#6
echo "======  docker push $IMAGE_BASE START======"
docker push $IMAGE_BASE
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "======  docker push $IMAGE_BASE ERROR======"
    exit $retVal
fi
echo "======  docker push $IMAGE_BASE DONE======"

echo "======  docker push $IMAGE_SPARK START======"
docker push $IMAGE_SPARK
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "======  docker push $IMAGE_SPARK ERROR======"
    exit $retVal
fi
echo "======  docker push $IMAGE_SPARK DONE======"

echo "======  docker push $IMAGE_SPARK_NOTEBOOK START======"
docker push $IMAGE_SPARK_NOTEBOOK
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "======  docker push $IMAGE_SPARK_NOTEBOOK ERROR======"
    exit $retVal
fi
echo "======  docker push $IMAGE_SPARK_NOTEBOOK DONE======"

echo "======  docker push $IMAGE_JOB START======"
docker push $IMAGE_JOB
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "======  docker push $IMAGE_JOB ERROR======"
    exit $retVal
fi
echo "======  docker push $IMAGE_JOB DONE======"


echo "$me after_push version=${docker_version}"
echo "$me after_push prefix=${IMAGE_PREFIX}"
echo "$me after_push spark=${IMAGE_SPARK}"
echo "$me after_push notebook=${IMAGE_SPARK_NOTEBOOK}"
echo "$me after_push livy=${IMAGE_LIVY}"
echo "$me after_push spark-job=${IMAGE_JOB}"

log_docker_versions $versionlogfile after_push $me

#
cd ../spark-job/tf
./scripts/destroy.sh $tenant_name spark
./scripts/apply.sh $tenant_name spark

cd ../
export SPARK_MASTER_IP=`cat ./build/oci-sparkmaster-ip`
echo "====== SPARK_MASTER_IP=$SPARK_MASTER_IP  ======"

#env

str="END `date` $me ARGS 1.spark_cluster_slave_count='$1' 2.spark_notebook_count='$2' 3.spark_job_name='$3' 4.docker_version='$4'============"
echo $str
echo $str >> $logfile


#sleep 360
