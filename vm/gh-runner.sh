#!/bin/bash
# Accept: ./launch.sh <count> [destroy]
COUNT=${1:-1}
DESTROY=${2:-}

export GH_RUNNER_COUNT=$COUNT

if [[ $DESTROY == "destroy" ]]; then
  echo "Destroying existing gh-runner-* VMs"
  # Destroy all VMs matching name pattern, without confirmation
  vagrant destroy -f
fi

echo "Starting $COUNT VMs"
vagrant up

