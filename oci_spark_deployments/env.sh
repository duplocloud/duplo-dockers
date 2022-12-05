export BUILDKIT_PROGRESS=plain
me=`basename "$0"`
export logfile="../$me.log"
export versionlogfile=../version_dockers.log
export versionsfile=../versions.log
export cmd_history_file=../cmd_history.log

# =============== cmd_history_file =========================================
echo "$me $1 $2 $3 $4"
echo "$me $1 $2 $3 $4" >> $cmd_history_file
# =============== cmd_history_file =========================================

# =============== parse args =========================================

str="`date` $me ARGS 1.spark_cluster_slave_count='$1' 2.spark_notebook_count='$2' 3.spark_job_name='$3' 4.docker_version='$4'============"
echo $str
echo $str >> $logfile

if [ -z "$4" ]
  then
     echo "USAGE "
     echo "$me 10 2 job66 v33"
     echo "$me SPARK_CLUSTER_SLAVE_COUNT    SPARK_NOTEBOOK_COUNT     SPARK_JOB_NAME    DOCKER_VERSION"
     exit 1
fi

spark_cluster_slave_count=${1:-10}
echo "argument 1 $1  spark_cluster_slave_count=$spark_cluster_slave_count"


spark_notebook_count=${2:-2}
echo "argument 2 $2 spark_notebook_count=$spark_notebook_count"

spark_job_name=${3:-jobs1}
echo "argument 3 $3 spark_job_name=$spark_job_name"

docker_version=${4:-v32}
echo "argument 4 $4 docker_version=$docker_version"

export spark_cluster_slave_count=$spark_cluster_slave_count
export spark_notebook_count=$spark_notebook_count
export spark_job_name=$spark_job_name
export docker_version=$docker_version

str="`date`  $me ARGS 1.spark_cluster_slave_count='$spark_cluster_slave_count' 2.spark_notebook_count='$spark_notebook_count' 3.spark_job_name='$spark_job_name' 4.docker_version='$docker_version'============"
echo $str
echo $str >> $logfile

# =============== parse args =========================================

# =============== docker version =========================================
source ./image_config.sh $docker_version
last_docker_version_file=LAST_DOCKER_VERSION.txt
echo "IMAGE_PREFIX=$IMAGE_PREFIX"
echo "IMAGE_VERSION=$IMAGE_VERSION"
echo $IMAGE_VERSION > $last_docker_version_file

export IMAGE_OS=centos:centos7
export IMAGE_BASE=${IMAGE_PREFIX}_base_${IMAGE_VERSION}
export IMAGE_SPARK=${IMAGE_PREFIX}_${IMAGE_VERSION}
export IMAGE_SPARK_NOTEBOOK=${IMAGE_PREFIX}_notebook_${IMAGE_VERSION}
export IMAGE_LIVY=${IMAGE_PREFIX}_livy_${IMAGE_VERSION}
export IMAGE_JOB=${IMAGE_PREFIX}_job_${IMAGE_VERSION}
# =============== docker version =========================================


# =============== backend.tf  =========================================
echo "=============set spark-job/tf/terraform/spark/backend.tf $3 $spark_job_name  ==========================="
backend_tf_file=spark-job/tf/terraform/spark/backend.tf
last_job_name_file=LAST_JOB_NAME.txt
touch $last_job_name_file
if [ -z "$3" ];
then
  echo "no argument 3 = $3  spark_job_name = $spark_job_name "
  cat $last_job_name_file 
else
  echo "$spark_job_name" > $last_job_name_file
  echo " argument 3 = $3  spark_job_name = $spark_job_name " 

cat <<EOF > $backend_tf_file
terraform {
  backend "s3" {
    workspace_key_prefix = "tenant:"
    region               = "us-west-2"
    key                  = "${spark_job_name}"
    encrypt              = true
  }
}
EOF
fi

echo "cat $backend_tf_file"
cat $backend_tf_file
# =============== backend.tf  =========================================


# ==================== TF_VAR======================
## == tf
export tenant_name="ashspark"

export TF_LOG=trace
export TF_LOG_PATH=/mnt/data/logs/flex4_terraform.log

export TF_VAR_oci_spark_cluster_prefix="$spark_job_name"
export TF_VAR_tenant_name=$tenant_name

export TF_VAR_oci_spark_cluster_slave_count=$spark_cluster_slave_count
export TF_VAR_oci_spark_notebook_count=$spark_notebook_count

## flex vm
export TF_VAR_notebook_node_instance_type="VM.Standard.E4.Flex"
export TF_VAR_notebook_node_memory_in_gbs=64
export TF_VAR_notebook_node_ocpus=8

export TF_VAR_slave_node_instance_type="VM.Standard.E4.Flex"
export TF_VAR_slave_node_memory_in_gbs=64
export TF_VAR_slave_node_ocpus=8

export TF_VAR_master_node_instance_type="VM.Standard.E4.Flex"
export TF_VAR_master_node_memory_in_gbs=64
export TF_VAR_master_node_ocpus=8

## docker
export TF_VAR_spark_master_docker_image="$IMAGE_SPARK"
export TF_VAR_spark_slave_docker_image="$IMAGE_SPARK"
export TF_VAR_spark_notebook_docker_image="$IMAGE_SPARK_NOTEBOOK"
## == tf
# ==========================================


# ==========================================
## == tf oracle  defined in ../duplo_env.sh
#export TF_VAR_oci_profile_user="$oci_profile_user"
#export TF_VAR_oci_profile_fingerprint="$oci_profile_fingerprint"
#export TF_VAR_oci_profile_key_file="$oci_profile_key_file"
#export TF_VAR_oci_profile_tenancy="$oci_profile_tenancy"
#export TF_VAR_oci_profile_region="$oci_profile_region"
#export TF_VAR_oci_profile_key_local_path="$oci_profile_key_local_path"
export TF_VAR_oci_instance_principal="instance_principal"

#
export TF_VAR_subnetid="$oci_subnetid"
export TF_VAR_availability_domain="$oci_availability_domain"
export TF_VAR_node_image_id="$oci_node_image_id"
## == tf oracle  defined in ../duplo_env.sh
# ==================== TF_VAR======================




                     


