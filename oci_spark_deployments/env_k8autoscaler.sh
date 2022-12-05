export BUILDKIT_PROGRESS=plain
me=`basename "$0"`
export logfile="../${me}.log"
export versionlogfile=../k8_as_version_dockers.log
export versionsfile=../k8_as_versions.log
export cmd_history_file=../k8_as_cmd_history.log

# =============== cmd_history_file =========================================
echo "$me $1"
echo "$me $1"  >> $cmd_history_file
# =============== cmd_history_file =========================================

# =============== parse args =========================================

str="`date` $me ARGS 1.name='$1'============"
echo $str
echo $str >> $logfile

if [ -z "$1" ]
  then
     echo "USAGE "
     echo "$me job66"
     echo "$me name"
     exit 1
fi

k8_as_name=${1:-jobs1}
echo "argument 1 $1  k8_as_name=$k8_as_name"
export k8_as_name=${k8_as_name}

str="`date`  $me ARGS 1.k8_as_name='$k8_as_name'============"
echo $str
echo $str >> $logfile

# =============== parse args =========================================



# =============== backend.tf  =========================================
echo "=============set spark-job/tf/terraform/spark/backend.tf $3 $k8_as_name  ==========================="
backend_tf_file=spark-job/tf/terraform/k8autoscaler/backend.tf
last_k8_as_name_file=LAST_K8_AS_NAME.txt
touch $last_k8_as_name_file
if [ -z "$1" ];
then
  echo "no argument 3 = $1  k8_as_name = $k8_as_name "
  cat $last_k8_as_name_file
else
  echo "$k8_as_name" > $last_k8_as_name_file
  echo " argument 1 = $1  k8_as_name = $k8_as_name "

cat <<EOF > $backend_tf_file
terraform {
  backend "s3" {
    workspace_key_prefix = "tenant:"
    region               = "us-west-2"
    key                  = "b${k8_as_name}"
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

#export TF_LOG=trace
#export TF_LOG_PATH=/mnt/data/logs/k8_as_terraform.log

export TF_VAR_tenant_name=$tenant_name

export TF_VAR_oci_k8_auto_scaler_prefix="$k8_as_name"
export TF_VAR_oci_k8_as_name=$k8_as_name

## flex vm
export TF_VAR_oci_k8_as_instance_type="VM.Standard.E4.Flex"
export TF_VAR_oci_k8_as_in_gbs=8
export TF_VAR_oci_k8_as_node_ocpus=2

export TF_VAR_oci_k8_ms_instance_type="VM.Standard.E4.Flex"
export TF_VAR_oci_k8_ms_in_gbs=8
export TF_VAR_oci_k8_ms_node_ocpus=2

#
export TF_VAR_oci_instance_principal="instance_principal"

#
export TF_VAR_subnetid="$oci_subnetid"
export TF_VAR_availability_domain="$oci_availability_domain"
export TF_VAR_node_image_id="$oci_node_image_id"
## == tf oracle  defined in ../duplo_env.sh
# ==================== TF_VAR======================








