#!/bin/bash -eu

# OS detection
case "$(uname -s)" in
Darwin)
  export TOOL_OS="darwin"
  ;;
Linux)
  export TOOL_OS="linux"
  ;;
esac

# Utility function for a fatal error.
die() {
  echo "$0:" "$@" 1>&2
  exit 1
}

# Utility function to log a command before running it.
logged() {
  echo "$0:" "$@" 1>&2
  "$@"
}

# Utility function to make a duplo API call with curl, and output JSON.
duplo_api() {
    local path="${1:-}"
    [ $# -eq 0 ] || shift

    [ -z "${path:-}" ] && die "internal error: no API path was given"
    [ -z "${duplo_host:-}" ] && die "internal error: duplo_host environment variable must be set"
    [ -z "${duplo_token:-}" ] && die "internal error: duplo_token environment variable must be set"
    echo " curl -Ssf -H 'Content-type: application/json' -H \"Authorization: Bearer $duplo_token\" \"$@\" \"${duplo_host}/${path}\""   1>&2
    curl -Ssf -H 'Content-type: application/json' -H "Authorization: Bearer $duplo_token" "$@" "${duplo_host}/${path}"
}

# Utility function to set up AWS credentials before running a command.
with_aws() {
  local duplo_tenant_id="${DUPLO_TENANT_ID:-}"

  # Run the command in the configured way.
  case "${AWS_RUNNER:-env}" in
  env)
    [ -z "${profile:-}" ] && die "internal error: no AWS profile selected"
    env AWS_PROFILE="$profile" AWS_SDK_LOAD_CONFIG=1 "$@"
    ;;
  duplo-admin)
    # Get just-in-time AWS credentials from Duplo and use them to execute the command.
    # shellcheck disable=SC2046     # NOTE: we want word splitting
    env $( duplo_api adminproxy/GetJITAwsConsoleAccessUrl |
            jq -r '{AWS_ACCESS_KEY_ID: .AccessKeyId, AWS_SECRET_ACCESS_KEY: .SecretAccessKey, AWS_REGION: .Region, AWS_DEFAULT_REGION: .Region, AWS_SESSION_TOKEN: .SessionToken} | to_entries | map("\(.key)=\(.value)") | .[]'
        ) AWS_SDK_LOAD_CONFIG=1 AWS_PROFILE='' "$@"
    ;;
  duplo)
    # Get just-in-time AWS credentials from Duplo and use them to execute the command.
    # shellcheck disable=SC2046     # NOTE: we want word splitting
    env $( duplo_api "subscriptions/${duplo_tenant_id}/GetAwsConsoleTokenUrl" |
            jq -r '{AWS_ACCESS_KEY_ID: .AccessKeyId, AWS_SECRET_ACCESS_KEY: .SecretAccessKey, AWS_REGION: .Region, AWS_DEFAULT_REGION: .Region, AWS_SESSION_TOKEN: .SessionToken} | to_entries | map("\(.key)=\(.value)") | .[]'
        ) AWS_SDK_LOAD_CONFIG=1 AWS_PROFILE='' "$@"
    ;;
  esac
}

# Utility function to run Terraform with AWS credentials.
# Also logs the command.
tf() {
  logged with_aws terraform "$@"
}

# Utility function to run "terraform init" with proper arguments, and clean state.
tf_init() {
  rm -f .terraform/environment .terraform/terraform.tfstate
  tf init "$@"
}
