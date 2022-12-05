
function  log_docker_versions {
message=$2
logfile=${1:-logfile}
cat <<EOF > $logfile
  `date` $IMAGE_VERSION $message start"
    ${IMAGE_PREFIX}
    ${IMAGE_SPARK}
    ${IMAGE_SPARK_NOTEBOOK}
    ${IMAGE_JOB}
  `date` $IMAGE_VERSION $message end"
EOF
}


