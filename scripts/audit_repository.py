"""Read-only cleanup checks; unresolved candidates are never deletion instructions."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCES = re.compile(r'["\']res://([^"\'\n]+)["\']')


def audit():
    errors, graph, references = [], {}, {}
    runtime = list((ROOT / "src").rglob("*.gd"))
    runtime += list((ROOT / "data").glob("*.json"))
    runtime += [ROOT / "main.tscn", ROOT / "project.godot"]
    runtime += [p for p in (ROOT / "assets").rglob("*")
                if p.suffix in [".tres", ".gdshader", ".gdshaderinc"]]
    for source in runtime:
        name = str(source.relative_to(ROOT))
        linked = set()
        for target in REFERENCES.findall(source.read_text()):
            if "%" in target or "*" in target or target.endswith("/"):
                continue
            if not Path(target).suffix:
                continue  # Directory/prefix composed with a later fragment.
            linked.add(target)
            references.setdefault(target, []).append(name)
            if not (ROOT / target).exists():
                errors.append(f"{name}: missing literal resource {target}")
        graph[name] = linked
    reached, pending = set(), {"main.tscn", "project.godot"}
    while pending:
        current = pending.pop()
        if current in reached:
            continue
        reached.add(current)
        pending.update(graph.get(current, set()) - reached)
    candidates = sorted(str(p.relative_to(ROOT)) for p in (ROOT / "src").rglob("*.gd")
                        if str(p.relative_to(ROOT)) not in reached)
    # Godot can resolve class_name identifiers without a literal preload.
    all_code = "\n".join(p.read_text() for p in (ROOT / "src").rglob("*.gd"))
    for name in candidates[:]:
        declaration = re.search(r'^class_name\s+(\w+)', (ROOT / name).read_text(), re.M)
        if declaration and len(re.findall(r'\b'+declaration[1]+r'\b', all_code)) > 1:
            candidates.remove(name)
    orphans = []
    for directory in ["src", "assets", "scripts", "tests"]:
        for path in (ROOT / directory).rglob("*"):
            if path.is_file() and path.suffix in [".uid", ".import"]:
                if not Path(str(path).removesuffix(path.suffix)).exists():
                    orphans.append(str(path.relative_to(ROOT)))
    errors.extend("orphan metadata: "+path for path in orphans)
    return {"runtime_text_files": len(runtime), "literal_resources": len(references),
            "errors": errors, "unreachable_script_candidates": candidates,
            "orphan_metadata": orphans,
            "note": "Dynamic asset paths require catalogue/consumer review and runtime tests."}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = audit()
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(f"REPOSITORY: {report['runtime_text_files']} files / "
          f"{len(report['errors'])} errors / "
          f"{len(report['unreachable_script_candidates'])} script candidates")
    for error in report["errors"]:
        print(error)
    raise SystemExit(bool(report["errors"]))
