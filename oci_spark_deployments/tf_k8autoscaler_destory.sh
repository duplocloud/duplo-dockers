
me=`basename "$0"`
export logfile="../$me.log"
str="START `date` $me ============ 1.jobname='$1' "
echo $str
echo "" >> $logfile
echo $str >> $logfile


if [ -z "$1" ]
  then
     echo "USAGE "
     echo "$me name"
     exit 1
fi

source ../duplo_env.sh
source ./env_k8autoscaler.sh  $jobname

cd base
#
cd ../spark-job/tf
./scripts/plan.sh $tenant_name k8autoscaler
./scripts/destroy.sh $tenant_name k8autoscaler


###############
echo "-- helm repo add prometheus-community https://prometheus-community.github.io/helm-charts"
/usr/local/bin/helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

echo "-- helm update"
/usr/local/bin/helm update

echo "-- helm uninstall prometheus"
/usr/local/bin/helm uninstall prometheus
#
#echo "-- helm install -f prometheus_values.yaml prometheus prometheus-community/kube-prometheus-stack"
#helm install -f prometheus_values.yaml prometheus prometheus-community/kube-prometheus-stack

###############
echo "-- helm uninstall  metrics-server metrics-server/metrics-server "
/usr/local/bin/helm uninstall  metrics-server

echo "-- helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/"
/usr/local/bin/helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

echo "-- helm update"
/usr/local/bin/helm update

#echo "-- helm upgrade --install metrics-server metrics-server/metrics-server"
#/usr/local/bin/helm upgrade --install metrics-server metrics-server/metrics-server

## /usr/local/bin/helm  show values   metrics-server/metrics-server
#
#echo "-- helm install -f  metrics_server_values.yaml metrics-server metrics-server/metrics-server"
#/usr/local/bin/helm  install -f  metrics_server_values.yaml metrics-server metrics-server/metrics-server

str="END `date`  $me ============ 1.jobname='$1' "
echo $str
echo $str >> $logfile


#sleep 360
