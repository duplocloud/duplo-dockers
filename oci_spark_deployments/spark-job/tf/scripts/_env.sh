#!/bin/bash -eu
profile="default"

#backend="-backend-config=bucket=duplo-tfstate-${AWS_ACCOUNT_ID} -backend-config=dynamodb_table=duplo-tfstate-${AWS_ACCOUNT_ID}-lock"
backend="-backend-config=bucket=duplo-tfstate-${AWS_ACCOUNT_ID}"

# Test required environment variables
for key in duplo_token duplo_host
do
  eval "[ -n \"\${${key}:-}\" ]" || die "error: $key: environment variable missing or empty"
done

export duplo_host profile backend AWS_ACCOUNT_ID
