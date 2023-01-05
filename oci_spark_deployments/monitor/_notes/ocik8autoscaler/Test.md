kubectl logs -f vishak7-k8autoscaler-svc-6c96cfb7b8-w8gvd 
+ DUPLO_SLAVE_NODE_POOLID=ocid1.nodepool.oc1.iad.aaaaaaaa66kpvpan56wbzyvfgcgugckjx6rbxulctou6gu7ocnzlaxhxgyoq
+ DUPLO_SCALE_MIN=25
DUPLO_SLAVE_NODE_POOLID ocid1.nodepool.oc1.iad.aaaaaaaa66kpvpan56wbzyvfgcgugckjx6rbxulctou6gu7ocnzlaxhxgyoq
DUPLO_SCALE_MAX 35
DUPLO_SCALE_MIN 25
+ DUPLO_SCALE_MAX=35
+ echo 'DUPLO_SLAVE_NODE_POOLID ocid1.nodepool.oc1.iad.aaaaaaaa66kpvpan56wbzyvfgcgugckjx6rbxulctou6gu7ocnzlaxhxgyoq'
+ echo 'DUPLO_SCALE_MAX 35'
+ echo 'DUPLO_SCALE_MIN 25'
+ ./cluster-autoscaler --v=4 --stderrthreshold=info --cloud-provider=oci --max-node-provision-time=25m --nodes=25:35:ocid1.nodepool.oc1.iad.aaaaaaaa66kpvpan56wbzyvfgcgugckjx6rbxulctou6gu7ocnzlaxhxgyoq --scale-down-delay-after-add=10m --scale-down-unneeded-time=10m --unremovable-node-recheck-timeout=5m --balance-similar-node-groups --balancing-ignore-label=oci.oraclecloud.com/fault-domain
I0727 21:38:50.107567       7 flags.go:52] FLAG: --add-dir-header="false"
I0727 21:38:50.107598       7 flags.go:52] FLAG: --address=":8085"
I0727 21:38:50.107601       7 flags.go:52] FLAG: --alsologtostderr="false"
I0727 21:38:50.107604       7 flags.go:52] FLAG: --aws-use-static-instance-list="false"
I0727 21:38:50.107606       7 flags.go:52] FLAG: --balance-similar-node-groups="true"
I0727 21:38:50.107609       7 flags.go:52] FLAG: --balancing-ignore-label="[oci.oraclecloud.com/fault-domain]"
I0727 21:38:50.107612       7 flags.go:52] FLAG: --cloud-config=""
I0727 21:38:50.107614       7 flags.go:52] FLAG: --cloud-provider="oci"
I0727 21:38:50.107616       7 flags.go:52] FLAG: --cloud-provider-gce-l7lb-src-cidrs="130.211.0.0/22,35.191.0.0/16"
I0727 21:38:50.107620       7 flags.go:52] FLAG: --cloud-provider-gce-lb-src-cidrs="130.211.0.0/22,209.85.152.0/22,209.85.204.0/22,35.191.0.0/16"
I0727 21:38:50.107625       7 flags.go:52] FLAG: --cluster-name=""
I0727 21:38:50.107628       7 flags.go:52] FLAG: --clusterapi-cloud-config-authoritative="false"
I0727 21:38:50.107630       7 flags.go:52] FLAG: --cordon-node-before-terminating="false"
I0727 21:38:50.107632       7 flags.go:52] FLAG: --cores-total="0:320000"
I0727 21:38:50.107635       7 flags.go:52] FLAG: --daemonset-eviction-for-empty-nodes="false"
I0727 21:38:50.107637       7 flags.go:52] FLAG: --estimator="binpacking"
I0727 21:38:50.107639       7 flags.go:52] FLAG: --expander="random"
I0727 21:38:50.107641       7 flags.go:52] FLAG: --expendable-pods-priority-cutoff="-10"
I0727 21:38:50.107644       7 flags.go:52] FLAG: --gce-concurrent-refreshes="1"
I0727 21:38:50.107646       7 flags.go:52] FLAG: --gpu-total="[]"
I0727 21:38:50.107648       7 flags.go:52] FLAG: --ignore-daemonsets-utilization="false"
I0727 21:38:50.107650       7 flags.go:52] FLAG: --ignore-mirror-pods-utilization="false"
I0727 21:38:50.107652       7 flags.go:52] FLAG: --ignore-taint="[]"
I0727 21:38:50.107654       7 flags.go:52] FLAG: --kubeconfig=""
I0727 21:38:50.107656       7 flags.go:52] FLAG: --kubernetes=""
I0727 21:38:50.107659       7 flags.go:52] FLAG: --leader-elect="true"
I0727 21:38:50.107662       7 flags.go:52] FLAG: --leader-elect-lease-duration="15s"
I0727 21:38:50.107665       7 flags.go:52] FLAG: --leader-elect-renew-deadline="10s"
I0727 21:38:50.107668       7 flags.go:52] FLAG: --leader-elect-resource-lock="leases"
I0727 21:38:50.107671       7 flags.go:52] FLAG: --leader-elect-resource-name="cluster-autoscaler"
I0727 21:38:50.107673       7 flags.go:52] FLAG: --leader-elect-resource-namespace=""
I0727 21:38:50.107675       7 flags.go:52] FLAG: --leader-elect-retry-period="2s"
I0727 21:38:50.107677       7 flags.go:52] FLAG: --log-backtrace-at=":0"
I0727 21:38:50.107682       7 flags.go:52] FLAG: --log-dir=""
I0727 21:38:50.107685       7 flags.go:52] FLAG: --log-file=""
I0727 21:38:50.107687       7 flags.go:52] FLAG: --log-file-max-size="1800"
I0727 21:38:50.107689       7 flags.go:52] FLAG: --logtostderr="true"
I0727 21:38:50.107692       7 flags.go:52] FLAG: --max-autoprovisioned-node-group-count="15"
I0727 21:38:50.107694       7 flags.go:52] FLAG: --max-bulk-soft-taint-count="10"
I0727 21:38:50.107696       7 flags.go:52] FLAG: --max-bulk-soft-taint-time="3s"
I0727 21:38:50.107699       7 flags.go:52] FLAG: --max-empty-bulk-delete="10"
I0727 21:38:50.107701       7 flags.go:52] FLAG: --max-failing-time="15m0s"
I0727 21:38:50.107704       7 flags.go:52] FLAG: --max-graceful-termination-sec="600"
I0727 21:38:50.107706       7 flags.go:52] FLAG: --max-inactivity="10m0s"
I0727 21:38:50.107709       7 flags.go:52] FLAG: --max-node-provision-time="25m0s"
I0727 21:38:50.107711       7 flags.go:52] FLAG: --max-nodes-total="0"
I0727 21:38:50.107713       7 flags.go:52] FLAG: --max-total-unready-percentage="45"
I0727 21:38:50.107716       7 flags.go:52] FLAG: --memory-total="0:6400000"
I0727 21:38:50.107718       7 flags.go:52] FLAG: --min-replica-count="0"
I0727 21:38:50.107721       7 flags.go:52] FLAG: --namespace="kube-system"
I0727 21:38:50.107723       7 flags.go:52] FLAG: --new-pod-scale-up-delay="0s"
I0727 21:38:50.107726       7 flags.go:52] FLAG: --node-autoprovisioning-enabled="false"
I0727 21:38:50.107728       7 flags.go:52] FLAG: --node-deletion-delay-timeout="2m0s"
I0727 21:38:50.107731       7 flags.go:52] FLAG: --node-group-auto-discovery="[]"
I0727 21:38:50.107733       7 flags.go:52] FLAG: --nodes="[25:35:ocid1.nodepool.oc1.iad.aaaaaaaa66kpvpan56wbzyvfgcgugckjx6rbxulctou6gu7ocnzlaxhxgyoq]"
I0727 21:38:50.107737       7 flags.go:52] FLAG: --ok-total-unready-count="3"
I0727 21:38:50.107739       7 flags.go:52] FLAG: --one-output="false"
I0727 21:38:50.107742       7 flags.go:52] FLAG: --profiling="false"
I0727 21:38:50.107744       7 flags.go:52] FLAG: --regional="false"
I0727 21:38:50.107746       7 flags.go:52] FLAG: --scale-down-candidates-pool-min-count="50"
I0727 21:38:50.107749       7 flags.go:52] FLAG: --scale-down-candidates-pool-ratio="0.1"
I0727 21:38:50.107752       7 flags.go:52] FLAG: --scale-down-delay-after-add="10m0s"
I0727 21:38:50.107754       7 flags.go:52] FLAG: --scale-down-delay-after-delete="0s"
I0727 21:38:50.107756       7 flags.go:52] FLAG: --scale-down-delay-after-failure="3m0s"
I0727 21:38:50.107759       7 flags.go:52] FLAG: --scale-down-enabled="true"
I0727 21:38:50.107762       7 flags.go:52] FLAG: --scale-down-gpu-utilization-threshold="0.5"
I0727 21:38:50.107764       7 flags.go:52] FLAG: --scale-down-non-empty-candidates-count="30"
I0727 21:38:50.107766       7 flags.go:52] FLAG: --scale-down-unneeded-time="10m0s"
I0727 21:38:50.107769       7 flags.go:52] FLAG: --scale-down-unready-time="20m0s"
I0727 21:38:50.107772       7 flags.go:52] FLAG: --scale-down-utilization-threshold="0.5"
I0727 21:38:50.107774       7 flags.go:52] FLAG: --scale-up-from-zero="true"
I0727 21:38:50.107776       7 flags.go:52] FLAG: --scan-interval="10s"
I0727 21:38:50.107779       7 flags.go:52] FLAG: --skip-headers="false"
I0727 21:38:50.107781       7 flags.go:52] FLAG: --skip-log-headers="false"
I0727 21:38:50.107783       7 flags.go:52] FLAG: --skip-nodes-with-local-storage="true"
I0727 21:38:50.107786       7 flags.go:52] FLAG: --skip-nodes-with-system-pods="true"
I0727 21:38:50.107788       7 flags.go:52] FLAG: --status-config-map-name="cluster-autoscaler-status"
I0727 21:38:50.107791       7 flags.go:52] FLAG: --stderrthreshold="0"
I0727 21:38:50.107793       7 flags.go:52] FLAG: --unremovable-node-recheck-timeout="5m0s"
I0727 21:38:50.107796       7 flags.go:52] FLAG: --user-agent="cluster-autoscaler"
I0727 21:38:50.107798       7 flags.go:52] FLAG: --v="4"
I0727 21:38:50.107801       7 flags.go:52] FLAG: --vmodule=""
I0727 21:38:50.107803       7 flags.go:52] FLAG: --write-status-configmap="true"
I0727 21:38:50.107811       7 main.go:391] Cluster Autoscaler 1.21.1