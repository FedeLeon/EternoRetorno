"""Run Godot regressions locally. No export and no user-save writes."""
import argparse
import concurrent.futures
import json
from pathlib import Path
import subprocess
import time
import sys
import os
from audit_content import audit

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--jobs', type=int, default=3)
parser.add_argument('--godot', default=str(ROOT / '.tools/Godot_v4.7.2-stable_linux.x86_64'))
parser.add_argument('--output', type=Path, default=ROOT / 'artifacts/polish/regressions')
args = parser.parse_args()
output = args.output
output.mkdir(parents=True, exist_ok=True)
catalogue = audit(ROOT)
(output / 'content.json').write_text(json.dumps(catalogue, indent=2) + '\n')
if catalogue['errors']:
    print('Content validation failed:', *catalogue['errors'], sep='\n')
    raise SystemExit(1)
validation_tests = subprocess.run([sys.executable, str(ROOT / 'tests/test_content_audit.py')],
                                capture_output=True, text=True, timeout=30)
(output / 'content-tests.log').write_text(validation_tests.stdout + validation_tests.stderr)
if validation_tests.returncode:
    print('Content validator tests failed; see content-tests.log')
    raise SystemExit(1)

def run(test):
    start = time.monotonic()
    test_env = os.environ.copy()
    test_env["XDG_DATA_HOME"] = str((output / "userdata" / test.stem).resolve())
    try:
        result = subprocess.run([args.godot, '--headless', '--audio-driver', 'Dummy', '--path', str(ROOT), '--script', str(test)], cwd=ROOT, env=test_env, capture_output=True, text=True, timeout=120)
        log = result.stdout + result.stderr
        code = result.returncode
    except subprocess.TimeoutExpired as error:
        log = str(error.stdout) + str(error.stderr)
        code = 124
    (output / (test.stem + '.log')).write_text(log)
    return {'test': test.name, 'exit': code, 'script_error': 'SCRIPT ERROR' in log, 'assertion_failure': 'FAIL:' in log, 'shutdown_warning': 'leaked at exit' in log, 'seconds': round(time.monotonic() - start, 2)}

with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.jobs)) as pool:
    results = list(pool.map(run, sorted((ROOT / 'tests').glob('test_*.gd'))))
(output / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
failures = [row for row in results if row['exit'] or row['script_error'] or row['assertion_failure']]
print(f'{len(results) - len(failures)}/{len(results)} suites passed')
for row in failures:
    print(row)
raise SystemExit(bool(failures))
