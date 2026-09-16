#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export JAVA_HOME="$PWD/.tools/jdk"
export ANDROID_HOME="$PWD/.tools/android"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"
godot_bin="${GODOT_BIN:-$PWD/.tools/Godot_v4.7.2-stable_linux.x86_64}"
mkdir -p builds
python3 scripts/configure_android.py
"$godot_bin" --headless --path . --import
"$godot_bin" --headless --path . --script tests/test_game.gd
"$godot_bin" --headless --path . --script tests/test_ui.gd
"$godot_bin" --headless --path . --script tests/test_warrior.gd
"$godot_bin" --headless --path . --export-debug Android builds/EternoRetorno-0.1.0-debug.apk
.tools/android/build-tools/36.0.0/apksigner verify --verbose builds/EternoRetorno-0.1.0-debug.apk
sha256sum builds/EternoRetorno-0.1.0-debug.apk > builds/SHA256SUMS
