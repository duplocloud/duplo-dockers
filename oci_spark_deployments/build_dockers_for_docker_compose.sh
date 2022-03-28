#get bash logs
export BUILDKIT_PROGRESS=plain

IMAGE_PREFIX=spark_3_2_1_ia
IMAGE_VERSION=v2
IMAGE_OS=centos:centos7
IMAGE_BASE=${IMAGE_PREFIX}_base_${IMAGE_VERSION}
IMAGE_SPARK=${IMAGE_PREFIX}_${IMAGE_VERSION}
IMAGE_SPARK_NOTEBOOK=${IMAGE_PREFIX}_notebook_${IMAGE_VERSION}
IMAGE_LIVY=${IMAGE_PREFIX}_livy_${IMAGE_VERSION}
IMAGE_JOB=${IMAGE_PREFIX}_job_${IMAGE_VERSION}


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


#4
cd ../spark-livy
parent_image=$IMAGE_SPARK
build_image=$IMAGE_LIVY
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


echo ${IMAGE_PREFIX}
echo ${IMAGE_SPARK}
echo ${IMAGE_SPARK_NOTEBOOK}
echo ${IMAGE_LIVY}
echo ${IMAGE_JOB}


