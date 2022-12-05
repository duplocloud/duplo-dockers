export versions=../versions.log

IMAGE_PREFIX=duplocloud/anyservice:spark_3_2_1_ia
IMAGE_VERSION=${1:-v31}

echo  "`date`: IMAGE_VERSION: $IMAGE_VERSION " >> $versions


log_docker_versions() {
  message="$2 $3"
  locallogfile=${1:-logfile}
  echo "`date`: $IMAGE_VERSION $message start" >> $locallogfile
  echo ${IMAGE_PREFIX} >> $locallogfile
  echo ${IMAGE_SPARK} >> $locallogfile
  echo ${IMAGE_SPARK_NOTEBOOK} >> $locallogfile
  echo ${IMAGE_JOB} >> $locallogfile
  echo "`date`: $IMAGE_VERSION $message end"  >> $locallogfile
}