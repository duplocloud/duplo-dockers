### prometheus-community helm chart

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





### old 












### metric server
* installed globally once for all clusters
 
### node_exporter
* install node_exporter on node ( part of image or using userdata to install node_exporter)
* installed inside image (default port), hence will be part of every node-pool instance.
* prometheus can be configured to use it.
 
### ocik8autoscaler
* build docker ( extends iad.ocir.io/oracle/oci-cluster-autoscaler:1.21.1-3)
* should be installed one pod per job. pass slave ocid to monitor
* downloaded from oracle cloud docker registry - iad.ocir.io/oracle/oci-cluster-autoscaler:1.21.1-3  
* addding startup.sh to docker. Configure and start "./cluster-autoscaler"

```
#!/bin/bash -x
# create one pod/docker per one  job === nodepool -- slave ??? min 1 max 5 ,  tf var for node pool
poolOcid=${poolOcid: -na}
 # ignore master and notebook
displayName=${displayName: -na}
./cluster-autoscaler \
--v=4 \
--stderrthreshold=info \
--cloud-provider=oci \
--max-node-provision-time=25m \
--nodes=1:5:$poolOcid \
--scale-down-delay-after-add=10m \
--scale-down-unneeded-time=10m \
--unremovable-node-recheck-timeout=5m \
--balance-similar-node-groups \
--balancing-ignore-label=$displayName \
--balancing-ignore-label=oci.oraclecloud.com/fault-domain
```
### prometheus
* extend  "prom/prometheus:latest".
* hope node_exporter installed on oci image is enough. (no cadvisor yet)
```yaml
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']

  - job_name: 'oci-sd'
    scrape_interval: 5s
    file_sd_configs:
    - files:
      - oci-sd.json
      refresh_interval: 1m
    relabel_configs:
    - source_labels: ['__meta_oci_public_ip']
      target_label: '__address__'
      replacement: '${1}:9100'
    - source_labels: ['__meta_oci_instance_id']
      target_label: 'instance_id'
    - source_labels: ['__meta_oci_instance_name']
      target_label: 'instance_name'
    - source_labels: ['__meta_oci_instance_state']
      target_label: 'instance_state'
    - source_labels: ['__meta_oci_freeform_tag_prometheus_exporter']
      target_label: 'prometheus_exporter'
    - source_labels: ['__meta_oci_freeform_tag_prometheus_exporter']
      regex: 'node_exporter'
      action: 'keep'
```


```yaml
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    file_sd_configs:
      - files:
          - 'node-exporters.json'
```
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