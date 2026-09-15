#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
exec "${GODOT_BIN:-$PWD/.tools/Godot_v4.7.2-stable_linux.x86_64}" --path . "$@"
