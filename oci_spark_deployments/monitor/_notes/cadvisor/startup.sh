#!/bin/bash -x
# create one pod/docker per one  job === nodepool -- slave ??? min 1 max 5 ,  tf var for node pool
DUPLO_SLAVE_NODE_POOLID=${DUPLO_SLAVE_NODE_POOLID:-na}
 # ignore master and notebook
ignorelabel=${ignorelabel: -na}


./cluster-autoscaler \
--v=4 \
--stderrthreshold=info \
--cloud-provider=oci \
--max-node-provision-time=25m \
--nodes=1:5:$DUPLO_SLAVE_NODE_POOLID \
--scale-down-delay-after-add=10m \
--scale-down-unneeded-time=10m \
--unremovable-node-recheck-timeout=5m \
--balance-similar-node-groups \
--balancing-ignore-label=$displayName \
--balancing-ignore-label=oci.oraclecloud.com/fault-domain

