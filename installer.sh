#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/scripts/install-docker.sh"
"$SCRIPT_DIR/scripts/create-docker-container.sh"
"$SCRIPT_DIR/scripts/fix-mt5-launcher.sh"
