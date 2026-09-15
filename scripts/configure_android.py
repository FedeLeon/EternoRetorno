#!/usr/bin/env python3
"""Configure the pinned Godot editor's Android export paths, preserving other settings."""
import json
import os
from pathlib import Path
import re
import shutil

root = Path(__file__).resolve().parents[1]
config = Path(os.environ.get('XDG_CONFIG_HOME', str(Path.home() / '.config')))
path = config / 'godot/editor_settings-4.7.tres'
if not path.exists():
    raise SystemExit('Primero ejecutá Godot con --headless --editor --import.')
backup = root / '.tools/editor-settings-before-android.tres'
if not backup.exists():
    shutil.copy2(path, backup)
text = path.read_text()
values = {
    'java_sdk_path': str(root / '.tools/jdk'),
    'android_sdk_path': str(root / '.tools/android'),
    'debug_keystore': str(root / '.tools/debug.keystore'),
    'debug_keystore_user': 'androiddebugkey',
    'debug_keystore_pass': 'android',
}
for key, value in values.items():
    name = 'export/android/' + key
    line = name + ' = ' + json.dumps(value)
    pattern = re.compile(r'^' + re.escape(name) + r' = .*$', re.MULTILINE)
    if pattern.search(text):
        text = pattern.sub(lambda match: line, text)
    else:
        text += '\n' + line + '\n'
temporary = path.with_suffix('.tres.tmp')
temporary.write_text(text)
temporary.replace(path)
print('Rutas de exportación Android configuradas; otras preferencias conservadas.')
