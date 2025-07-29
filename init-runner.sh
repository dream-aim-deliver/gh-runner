#!/usr/bin/env bash

set -euxo pipefail

echo "Running GH runner initialization on node $RUNNER_INDEX"

for var in REPO_URL RUNNER_LABELS RUNNER_INDEX GH_ORG_PAT RUNNER_VERSION ORG_NAME; do
  if [ -z "${!var:-}" ]; then
    echo "❌ $var is not set."
    exit 1
  fi
done


echo "Initializing GitHub Actions runner on VM $RUNNER_INDEX"

runner_name=gh-runner-$RUNNER_INDEX

# === System setup ===
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    curl \
    sudo \
    git \
    jq \
    unzip \
    gnupg2 \
    ca-certificates \
    libicu70 \
    libkrb5-3 \
    libssl3 \
    libunwind8 \
    libcurl4 \
    wget \
    lsb-release

# === Install GitHub CLI ===
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt-get update
sudo apt-get install -y gh

# === Create runner user ===
sudo useradd -m -d /home/runneruser/runner -s /bin/bash runneruser || true
echo "runneruser ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/runneruser
sudo chmod 440 /etc/sudoers.d/runneruser

# === Docker CLI install ===
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-ce-cli

# Add runneruser to docker group
sudo groupadd docker || true
sudo usermod -aG docker runneruser


# === Create token for the runner ===
echo "🧹 Checking for existing runner named $runner_name..."
existing_runners=$(curl -s -X GET \
  -H "Authorization: Bearer $GH_ORG_PAT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/orgs/$ORG_NAME/actions/runners")

runner_id=$(echo "$existing_runners" | jq ".runners[] | select(.name == \"$runner_name\") | .id")

if [ -n "$runner_id" ]; then
  echo "⚠️ Runner '$runner_name' already exists with ID $runner_id, deleting..."

  delete_response=$(curl -s -X DELETE \
    -H "Authorization: Bearer $GH_ORG_PAT" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/orgs/$ORG_NAME/actions/runners/$runner_id")

  echo "🗑️ Deleted runner '$runner_name'"
else
  echo "✅ No existing runner named '$runner_name'"
fi

# Get registration token from GitHub API
response=$(curl -s -X POST \
  -H "Authorization: Bearer $GH_ORG_PAT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/orgs/$ORG_NAME/actions/runners/registration-token")

# Extract token using jq
token=$(echo "$response" | jq -r '.token')

if [ "$token" == "null" ] || [ -z "$token" ]; then
  echo "❌ Failed to retrieve runner token for runner #$i"
  echo "🔎 Response: $response"
  exit 1
fi


# === Register Runner ===
INSTALL_DIR=/home/runneruser/runner

sudo -u runneruser bash <<EOF
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    curl -L -o actions-runner.tar.gz "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
    tar xzf actions-runner.tar.gz
    rm actions-runner.tar.gz

    ./config.sh --unattended --url "${REPO_URL}" --token "${token}" --name "$runner_name" --labels ${RUNNER_LABELS}

    nohup ./run.sh &> /home/runneruser/runner/runner.log &
EOF
