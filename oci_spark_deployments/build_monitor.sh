
curfolder=`pwd`
monitorfolder=$curfolder/monitor

cd $monitorfolder/ocik8autoscaler
# monitor/ocik8autoscaler folder

docker build -t duplocloud/anyservice:ocik8autoscaler-1.21.1-3_v1 .
docker push duplocloud/anyservice:ocik8autoscaler-1.21.1-3_v1

cd $monitorfolder/node-exporter
# monitor/ocik8autoscaler folder

docker build -t duplocloud/anyservice:node-exporter-1.21.1-3_v1 .
docker push duplocloud/anyservice:node-exporter-1.21.1-3_v1



cd $monitorfolder/prometheus

# manually
# Build and update in Duplo-ui with new version
#
docker build -t duplocloud/anyservice:ociprometheus_v29 .
docker push     duplocloud/anyservice:ociprometheus_v29

# monitor/prometheus folder
docker build -t duplocloud/anyservice:ociprometheus_v1 .
docker push duplocloud/anyservice:ociprometheus_v1


cd $monitorfolder/used
# monitor/used folder

#update manually metricserver.yaml , daemonset-node-exporter.yaml, cadvidor.yaml
# and delete + apply to recreate
#kubectl delete -f metricserver.yaml
#kubectl apply -f metricserver.yaml
#
#kubectl delete -f daemonset-node-exporter.yaml
#kubectl apply -f daemonset-node-exporter.yaml
#
#kubectl delete -f cadvidor.yaml
#kubectl apply -f cadvidor.yaml


cd $curfolder



