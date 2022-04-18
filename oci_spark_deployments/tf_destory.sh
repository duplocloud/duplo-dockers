#get bash logs
export BUILDKIT_PROGRESS=plain

source ../env.sh

source ./image_config.sh
echo "IMAGE_PREFIX=$IMAGE_PREFIX"
echo "IMAGE_VERSION=$IMAGE_VERSION"
#IMAGE_PREFIX=duplocloud/anyservice:spark_3_2_1_ia
#IMAGE_VERSION=v999

IMAGE_OS=centos:centos7
IMAGE_BASE=${IMAGE_PREFIX}_base_${IMAGE_VERSION}
IMAGE_SPARK=${IMAGE_PREFIX}_${IMAGE_VERSION}
IMAGE_SPARK_NOTEBOOK=${IMAGE_PREFIX}_notebook_${IMAGE_VERSION}
IMAGE_LIVY=${IMAGE_PREFIX}_livy_${IMAGE_VERSION}
IMAGE_JOB=${IMAGE_PREFIX}_job_${IMAGE_VERSION}



echo ${IMAGE_PREFIX}
echo ${IMAGE_SPARK}
echo ${IMAGE_SPARK_NOTEBOOK}
echo ${IMAGE_LIVY}
echo ${IMAGE_JOB}





cd ./spark-job/tf
./scripts/destroy.sh ashspark spark

