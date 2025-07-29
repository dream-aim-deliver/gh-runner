#!/bin/bash
echo "Running GH runner initialization on node $RUNNER_INDEX"
# Example installation steps:
sudo apt-get update
sudo apt-get install -y curl jq
# e.g., download GitHub runner and register:
mkdir -p /home/vagrant/actions-runner
cd actions-runner
curl -O -L https://github.com/actions/runner/releases/download/v2.x.x/actions-runner-linux-x64-2.x.x.tar.gz
tar xzf *.tar.gz
# then registration using token (provided somehow or via env)
echo "Runner ${RUNNER_INDEX} initialized"

