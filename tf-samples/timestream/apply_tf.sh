#!/bin/bash -ex

source ./env.sh

tenant=${TF_VAR_tenant_name:ts-t}
folder=app
./scripts/apply.sh $tenant $folder
