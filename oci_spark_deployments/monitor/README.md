###   metrics-server 
 
```shell
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ 
helm upgrade --install metrics-server metrics-server/metrics-server

helm show values   metrics-server/metrics-server  
helm install -f  metrics_server_values.yaml metrics-server metrics-server/metrics-server  

helm uninstall  metrics-server metrics-server/metrics-server  

```




### prometheus-community helm chart
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install -f prometheus_values.yaml prometheus prometheus-community/kube-prometheus-stack prometheus
helm update

helm uninstall prometheus 
helm install -f prometheus_values.yaml prometheus prometheus-community/kube-prometheus-stack

* prometheus_values.yaml
```yaml

alertmanager:
  alertmanagerSpec:
    nodeSelector:
      allocationtags: 'k8-monitoring'
  service:
    type: NodePort

prometheus:
  prometheusSpec:
    allocationtags: 'k8-monitoring'
  service:
    type: NodePort

grafana:
  grafanaSpec:
    allocationtags: 'k8-monitoring'
  service:
    type: NodePort



```

### info 
```bash
helm show values prometheus-community/kube-prometheus-stack  > ~/Downloads/prometheus-values.yaml
kubectl --namespace duploservices-ashspark get pods -l "release=prometheus"

get service prometheus-grafana   -o json
get service prometheus-kube-prometheus-prometheus      -o json

```

 
find ip and prometheus-grafana and prometheus-kube-prometheus-prometheus
"nodePort": 30090
access using node ip and port




###  old 
https://raw.githubusercontent.com/bibinwilson/kubernetes-prometheus/master/config-map.yaml
https://github.com/search?q=org%3Aduplocloud+prometheus&type=code
https://www.robustperception.io/filesystem-metrics-from-the-node-exporter/
```markdown
CPU Usage

100 - (avg(irate(node_cpu{mode="idle", instance=~"$instance"}[1m])) * 100)

Memory Usage (10^9 refers to GB)

node_memory_MemAvailable{instance="$instance"}/10^9

node_memory_MemTotal{instance="$instance"}/10^9

Disk Space Usage: Free Inodes vs. Total Inodes

node_filesystem_free{mountpoint="/", instance="$instance"}/10^9

Network Ingress

node_network_receive_bytes_total{instance=”$instance”}/10^9

Network Egress

node_network_transmit_bytes_total{instance=”$instance”}/10^9

Cluster CPU Usage

sum (rate (container_cpu_usage_seconds_total{id="/"}[1m])) / sum (machine_cpu_cores) * 100

Pod CPU Usage

sum (rate (container_cpu_usage_seconds_total{image!=""}[1m])) by (pod_name)

IO Usage by Container

sum(container_fs_io_time_seconds_total{name=~"./"}) by (name)
```

https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts


helm install -f prometheus_values.yaml prometheus prometheus-community/kube-prometheus-stack prometheus
helm install grafana grafana/grafana-agent-operator

helm install prometheus prometheus-community/prometheus \
--namespace duploservices-ashspark \
--set alertmanager.persistentVolume.storageClass="default" \
--set server.persistentVolume.storageClass="default"

helm show values prometheus-community/kube-prometheus-stack  > ~/Downloads/prometheus-values.yaml
kubectl --namespace duploservices-ashspark get pods -l "release=prometheus"


(node_memory_MemAvailable_bytes ) / 1024 / 1024
(instance_memory_limit_bytes - instance_memory_usage_bytes) / 1024 / 1024
100 - 100 * (avg(irate(node_cpu_seconds_total{node="$node",job="kubernetes-service-endpoints",cpu="$cpu",mode="idle"}[1m])))


https://blog.ruanbekker.com/cheatsheets/prometheus/



100 - 100 * (avg(irate(node_cpu_seconds_total{instance="INSTANCE",job="JOB",replica="REPLICA",mode="idle"}[1m])))

node_cpu_seconds_total{app="prometheus", app_kubernetes_io_managed_by="Helm", chart="prometheus-15.10.5", 
component="node-exporter", cpu="0", heritage="Helm", instance="10.0.10.109:9100",
job="kubernetes-service-endpoints", mode="idle", namespace="duploservices-ashspark", node="10.0.10.109", release="prometheus", service="prometheus-node-exporter"}	300667.46

100 - 100 * (avg(irate(node_cpu_seconds_total{node="10.0.10.109",job="kubernetes-service-endpoints",mode="idle"}[1m])))
node="10.0.10.109"

grafana
adminPassword: prom-operator
get service prometheus-grafana   -o json

get service prometheus-kube-prometheus-prometheus      -o json
"nodePort": 30090

http://prometheus-kube-prometheus-prometheus.duploservices-ashspark:9090/



kube-state-metrics:
...
  extraArgs:
    - --metric-labels-allowlist=nodes=[*],pods=[*],persistentvolumeclaims=[*],deployments=[*],statefulsets=[*],configmaps=[*],secrets=[*],services=[*],replicasets=[*]
...


For pods only, and all their labels, you would use e.g.

kube-state-metrics:
...
  extraArgs:
    - --metric-labels-allowlist=pods=[*]
...


###  cadvidor 
https://stackoverflow.com/questions/69406120/changing-prometheus-job-label-in-scraper-for-cadvisor-breaks-grafana-dashboards


I installed Prometheus on my Kubernetes cluster with Helm, using the community chart kube-prometheus-stack 
- and I get some beautiful dashboards in the bundled Grafana instance. 
- I now wanted the recommender from the Vertical Pod Autoscaler to use Prometheus as
- a data source for historic metrics, as described here. Meaning, I had to make a change to the Prometheus
- scraper settings for cAdvisor, and this answer pointed me in the right direction, as after making that
- change I can now see the correct job tag on metrics from cAdvisor.
- 

Unfortunately, now some of the charts in the Grafana dashboards are broken. 
It looks like it no longer picks up the CPU metrics - and instead just displays "No data" for the 
CPU-related charts.

So, I assume I have to tweak the charts to be able to pick up the metrics correctly again, 
but I don't see any obvious places to do this in Grafana?

Not sure if it is relevant for the question, but I am running my Kubernetes cluster on Azure Kubernetes 
Service (AKS).

This is the full values.yaml I supply to the Helm chart when installing Prometheus:

kubeControllerManager:
  enabled: false
kubeScheduler:
  enabled: false
kubeEtcd:
  enabled: false
kubeProxy:
  enabled: false
kubelet:
  serviceMonitor:
    # Diables the normal cAdvisor scraping, as we add it with the job name "kubernetes-cadvisor" under additionalScrapeConfigs
    # The reason for doing this is to enable the VPA to use the metrics for the recommender
    # https://github.com/kubernetes/autoscaler/blob/master/vertical-pod-autoscaler/FAQ.md#how-can-i-use-prometheus-as-a-history-provider-for-the-vpa-recommender
    cAdvisor: false
prometheus:
  prometheusSpec:
    retention: 15d
    storageSpec:
      volumeClaimTemplate:
        spec:
          # the azurefile storage class is created automatically on AKS
          storageClassName: azurefile
          accessModes: ["ReadWriteMany"]
          resources:
            requests:
              storage: 50Gi
    additionalScrapeConfigs:
      - job_name: 'kubernetes-cadvisor'
        scheme: https
        metrics_path: /metrics/cadvisor
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
Kubernetes version: 1.21.2

kube-prometheus-stack version: 18.1.1

helm version: version.BuildInfo{Version:"v3.6.3", GitCommit:"d506314abfb5d21419df8c7e7e68012379db2354", GitTreeState:"dirty",







######
prometheus-kube-prometheus-kubelet service
"ports": [
          {   
              "name": "https-metrics",
              "port": 10250,
              "protocol": "TCP",
              "targetPort": 10250
          },
          {   
              "name": "http-metrics",
              "port": 10255,
              "protocol": "TCP",
              "targetPort": 10255
          },
          {
              "name": "cadvisor",
              "port": 4194,
              "protocol": "TCP",
              "targetPort": 4194
          }
      ],



