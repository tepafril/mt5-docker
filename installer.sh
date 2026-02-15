#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/scripts/install-docker.sh"
bash "$SCRIPT_DIR/scripts/create-docker-container.sh"
(cd "$SCRIPT_DIR/scripts" && bash fix-mt5-launcher.sh)
