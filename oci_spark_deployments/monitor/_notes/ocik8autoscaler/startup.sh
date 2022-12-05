#!/bin/bash -x
# create one pod/docker per one  job === nodepool -- slave ??? min 1 max 5 ,  tf var for node pool
DUPLO_SLAVE_NODE_POOLID=${DUPLO_SLAVE_NODE_POOLID:-na}
OCI_SLAVE_NODE_SCALE_MIN=${OCI_SLAVE_NODE_SCALE_MIN:-3}
OCI_SLAVE_NODE_SCALE_MAX=${OCI_SLAVE_NODE_SCALE_MAX:-30}
OCI_SLAVE_NODE_SCALE_REGION=${OCI_SLAVE_NODE_SCALE_REGION:-us-ashburn-1}
echo "DUPLO_SLAVE_NODE_POOLID $DUPLO_SLAVE_NODE_POOLID"
echo "OCI_SLAVE_NODE_SCALE_MIN $OCI_SLAVE_NODE_SCALE_MIN"
echo "OCI_SLAVE_NODE_SCALE_MAX $OCI_SLAVE_NODE_SCALE_MAX"
echo "OCI_SLAVE_NODE_SCALE_REGION $OCI_SLAVE_NODE_SCALE_REGION"

export OCI_USE_INSTANCE_PRINCIPAL="true"
export OCI_REGION=$OCI_SLAVE_NODE_SCALE_REGION

./cluster-autoscaler \
--v=4 \
--stderrthreshold=info \
--cloud-provider=oci \
--max-node-provision-time=25m \
--nodes=$OCI_SLAVE_NODE_SCALE_MIN:$OCI_SLAVE_NODE_SCALE_MAX:$DUPLO_SLAVE_NODE_POOLID \
--scale-down-delay-after-add=10m \
--scale-down-unneeded-time=10m \
--unremovable-node-recheck-timeout=5m \
--balancing-ignore-label=oci.oraclecloud.com/fault-domain \
--leader-elect=false



# # ignore master and notebook
#displayName=${$displayName: -na}
#ignorelabel="--balancing-ignore-label=$displayName"

#--cloud-provider=oci \ #--cloud-provider=oke
#--namespace="duploservices-ashspark" \

#./cluster-autoscaler \
#--v=4 \
#--stderrthreshold=info \
#--cloud-provider=oke \
#--max-node-provision-time=25m \
#- name: $OCI_SLAVE_NODE_SCALE_REGION
#--nodes=$OCI_SLAVE_NODE_SCALE_MIN:$OCI_SLAVE_NODE_SCALE_MAX:$DUPLO_SLAVE_NODE_POOLID \
#--scale-down-delay-after-add=10m \
#--scale-down-unneeded-time=10m \
#--unremovable-node-recheck-timeout=5m \
#--balance-similar-node-groups \
#--balancing-ignore-label=oci.oraclecloud.com/fault-domain
