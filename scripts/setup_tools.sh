#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .tools downloads .tools/templates .tools/jdk .tools/android/cmdline-tools
fetch() { if [[ ! -s "$2" ]]; then curl -fL --retry 3 "$1" -o "$2.part"; mv "$2.part" "$2"; fi; }
version=4.7.2
base="https://github.com/godotengine/godot-builds/releases/download/${version}-stable"
if [[ ! -x ".tools/Godot_v${version}-stable_linux.x86_64" ]]; then
  fetch "$base/Godot_v${version}-stable_linux.x86_64.zip" downloads/godot.zip
  unzip -qo downloads/godot.zip -d .tools
fi
if [[ ! -s .tools/templates/templates/android_debug.apk ]]; then
  fetch "$base/Godot_v${version}-stable_export_templates.tpz" downloads/templates.tpz
  unzip -qo downloads/templates.tpz 'templates/android_debug.apk' 'templates/android_release.apk' 'templates/version.txt' -d .tools/templates
fi
if [[ ! -x .tools/jdk/bin/java ]]; then
  fetch 'https://api.adoptium.net/v3/binary/version/jdk-17.0.20.1%2B1/linux/x64/jdk/hotspot/normal/eclipse' downloads/jdk.tar.gz
  tar -xzf downloads/jdk.tar.gz --strip-components=1 -C .tools/jdk
fi
if [[ ! -x .tools/android/cmdline-tools/latest/bin/sdkmanager ]]; then
  fetch 'https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip' downloads/android.zip
  unzip -qo downloads/android.zip -d .tools/android/cmdline-tools
  mv .tools/android/cmdline-tools/cmdline-tools .tools/android/cmdline-tools/latest
fi
export JAVA_HOME="$PWD/.tools/jdk"
export ANDROID_HOME="$PWD/.tools/android"
# sdkmanager displays the licenses and requests acceptance in the terminal.
.tools/android/cmdline-tools/latest/bin/sdkmanager --sdk_root="$ANDROID_HOME" --licenses
.tools/android/cmdline-tools/latest/bin/sdkmanager --sdk_root="$ANDROID_HOME" 'platform-tools' 'build-tools;36.0.0' 'platforms;android-36'
if [[ ! -f .tools/debug.keystore ]]; then
  .tools/jdk/bin/keytool -genkeypair -keystore .tools/debug.keystore -storepass android -alias androiddebugkey -keypass android -dname 'CN=Android Debug,O=Android,C=US' -keyalg RSA -keysize 2048 -validity 10000
fi
.tools/Godot_v4.7.2-stable_linux.x86_64 --headless --path . --editor --import --quit
python3 scripts/configure_android.py
