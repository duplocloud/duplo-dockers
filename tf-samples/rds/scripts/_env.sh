#!/bin/bash -eu
AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"
backend="-backend-config=bucket=duplo-tfstate-${AWS_ACCOUNT_ID} -backend-config=dynamodb_table=duplo-tfstate-${AWS_ACCOUNT_ID}-lock -backend-config=region=${backend_region}"
TF_VAR_s3_backend_region="${backend_region}"
# Test required environment variables
for key in duplo_token duplo_host
do
  eval "[ -n \"\${${key}:-}\" ]" || die "error: $key: environment variable missing or empty"
done

export duplo_host duplo_token duplo_default_tenant_id backend AWS_ACCOUNT_ID TF_VAR_s3_backend_region
