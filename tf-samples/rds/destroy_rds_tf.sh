#!/bin/bash -ex

source ./env.sh
tenant=${TF_VAR_tenant_name:ts-t}
folder=rds
./scripts/destroy.sh $tenant $folder
