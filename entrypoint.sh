#!/usr/bin/env bash

set -e

if [[ -z "${REPO_URL}" || -z "${RUNNER_TOKEN}" ]]; then
  echo "Missing REPO_URL or RUNNER_TOKEN env vars"
  exit 1
fi

# Optional: label customization
if [[ -n "${RUNNER_LABELS}" ]]; then
  LABELS="--labels ${RUNNER_LABELS}"
else
  LABELS=""
fi

./config.sh \
  --unattended \
  --url "${REPO_URL}" \
  --token "${RUNNER_TOKEN}" \
  --name "${RUNNER_NAME:-$(hostname)}" \
  ${LABELS}

trap 'echo "Removing runner..."; ./config.sh remove --unattended --token "${RUNNER_TOKEN}"; exit 0' SIGINT SIGTERM

./run.sh
