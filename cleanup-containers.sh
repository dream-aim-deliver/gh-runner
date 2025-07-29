#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    echo "Force-removes containers starting with a name prefix"
    echo "Usage: $0 <prefix>"
    exit 1
fi

docker ps -a --filter "name=^/$1" --format '{{.ID}}' | xargs -r docker rm -f
