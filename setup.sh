#!/usr/bin/env bash

set -euo pipefail

echo "[Step 1] Loading and validating environment variables..."

# Load environment variables from .env
if [ ! -f .env ]; then
  echo "❌ .env file not found. Please create one following the .env.template file."
  exit 1
fi

source .env

# Validate required env vars
for var in GH_ORG_PAT ORG_NAME REPO_URL RUNNER_LABELS RUNNER_COUNT DOCKER_GID; do
  if [ -z "${!var:-}" ]; then
    echo "❌ $var is not set in the .env file."
    exit 1
  fi
done
echo "[Step 1] ✅ Done!"


echo "[Step 2] Creating and registering ${RUNNER_COUNT} runner images..."

# Loop to create and register runners
for i in $(seq 1 "$RUNNER_COUNT"); do
  echo "🔁 Creating token for runner #$i..."
  runner_name="gh-runner-$i"

  # Check if a runner with the same name already exists
  echo "🧹 Checking for existing runner named gh-runner-$i..."

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

  echo "🚀 Building gh-runner-$i..."

  docker build -t gh-runner-$i \
    --build-arg REPO_URL="$REPO_URL" \
    --build-arg RUNNER_TOKEN="$token" \
    --build-arg RUNNER_NAME="$runner_name" \
    --build-arg RUNNER_LABELS="$RUNNER_LABELS" \
    --build-arg DOCKER_GID="$DOCKER_GID" \
    .

  echo "✅ Built gh-runner-$i"
done

echo "[Step 2] ✅ All runners built and configured successfully."


echo "[Step 3] Generating docker-compose file..."

cat > docker-compose.yml <<EOF
services:
EOF

for i in $(seq 1 "$RUNNER_COUNT"); do
  cat >> docker-compose.yml <<EOF
  gh-runner-$i:
    image: gh-runner-$i
    container_name: gh-runner-$i
    restart: always
    volumes:
      - gh-runner-data-$i:/runner
      - /var/run/docker.sock:/var/run/docker.sock

EOF
done

# Add volumes block
cat >> docker-compose.yml <<EOF
volumes:
EOF

for i in $(seq 1 "$RUNNER_COUNT"); do
  echo "  gh-runner-data-$i:" >> docker-compose.yml
done

echo "[Step 3] ✅ docker-compose.yml generated with $RUNNER_COUNT runners"


echo "✅ Setup finalized correctly!"

