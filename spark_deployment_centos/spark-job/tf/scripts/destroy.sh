#!/bin/bash -eu
tenant="$1" ; shift
case "$tenant" in
default|compliance)
  echo "Tenant cannot be named: $tenant" 1>&2
  exit 1
esac

# Which project to run.
selection="${1:-}"
[ $# -eq 0 ] || shift

# Load environment and utility programs.
export tenant
# shellcheck disable=SC1091    # VS code won't enable following the files.
source "$(dirname "${BASH_SOURCE[0]}")/_util.sh"
# shellcheck disable=SC1091    # VS code won't enable following the files.
source "$(dirname "${BASH_SOURCE[0]}")/_env.sh"

# Utility function to run "terraform destroy" with proper arguments, and clean state.
function tf_destroy() {
  local project="$1" ; shift

  [ -z "${backend:-}" ] && die "internal error: backend should have been configured by _env.sh"

  # Skip projects that are not selected.
  if [ -n "$selection" ] && [ "$selection" != "$project" ]; then
    return 0;
  fi

  # Determine the terraform workspace.
  local ws="$tenant"

  local tf_args=( -auto-approve -input=false )

  local varfile="configs/$ws/$project.tfvars.json"
  [ -f "$varfile" ] && tf_args=( "${tf_args[@]}" "-var-file=../../$varfile" )

  echo "Project: $project"

  # shellcheck disable=SC2086    # NOTE: we want word splitting
  (cd "terraform/$project" &&
      tf_init $backend &&
      if tf workspace select "$ws"; then
        tf destroy "${tf_args[@]}" && tf workspace select default && tf workspace delete "$ws"
      fi)
}

tf_output() {
    local project="$1" ; shift

    # Determine the terraform workspace.
    local ws="$tenant"

    # shellcheck disable=SC2086    # NOTE: we want word splitting
    (cd "terraform/$project" &&
        tf_init $backend 1>&2 &&
        ( tf workspace select "$ws" 1>&2 || tf workspace new "$ws" 1>&2 ) &&
        tf output -json )
}

tf_destroy spark "$@"
