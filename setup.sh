#!/usr/bin/env bash

set -euo pipefail

function usage() {
cat << EOF
$0 [ [-h | --help] | [-d | --destroy] ]
  Setups VMs and register them as GitHub runners.
  Passing -d / --destroy argument forces-destroys all previous VMs named the same.
  Passing -h / --help shows this message and quits.
EOF
}

echo "Loading and validating environment variables..."

# Load environment variables from .env
if [ ! -f .env ]; then
  echo "❌ .env file not found. Please create one following the .env.template file."
  exit 1
fi

source .env

# Validate required env vars
for var in GH_ORG_PAT ORG_NAME REPO_URL RUNNER_LABELS RUNNER_COUNT RUNNER_VERSION; do
  if [ -z "${!var:-}" ]; then
    echo "❌ $var is not set in the .env file."
    exit 1
  fi
done
echo "✅ Done!"

case "$1" in
  -h | --help)
  usage
  exit 1
  ;;

  -d | --destroy)
  DESTROY="true"
  ;;
esac


if [[ $DESTROY == "true" ]]; then
  echo "Destroying existing gh-runner-* VMs"
  # Destroy all VMs matching name pattern, without confirmation
  vagrant destroy -f
fi

echo "Starting $RUNNER_COUNT VMs"
vagrant up

