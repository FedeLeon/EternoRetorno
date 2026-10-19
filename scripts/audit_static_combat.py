"""Validate individual static action drawings and the retired animation surface."""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "art_sources/static_combat_2026_10_19"
ACTIONS = {"idle", "attack", "guard", "skill", "hurt", "death"}


def audit():
    catalog = json.loads((ROOT / "data/static_combat.json").read_text())
    records = json.loads((DOC / "extraction.json").read_text())
    errors, drawings = [], []
    for kind, entries in catalog.items():
        for identity, poses in entries.items():
            if set(poses) != ACTIONS:
                errors.append(f"{kind}/{identity}: incomplete action coverage")
            for action, pose in poses.items():
                key = f"{kind}/{identity}/{action}"
                path = ROOT / pose["path"].removeprefix("res://")
                if not path.is_file():
                    errors.append(f"{key}: missing illustration")
                    continue
                with Image.open(path) as image:
                    bounds = image.getchannel("A").point(lambda a: 255 if a > 127 else 0).getbbox()
                    if image.width != image.height or image.width > 512:
                        errors.append(f"{key}: expected one square drawing, not an atlas")
                    if not bounds or min(bounds[2]-bounds[0],bounds[3]-bounds[1]) < 20:
                        errors.append(f"{key}: empty/tiny drawing")
                    elif bounds[3] != pose["anchor"][1]:
                        errors.append(f"{key}: incorrect ground anchor")
                source = ROOT / records[key]["source"]
                if hashlib.sha256(source.read_bytes()).hexdigest() != records[key]["source_sha256"]:
                    errors.append(f"{key}: selected source hash changed")
                drawings.append({"id": key, "path": str(path.relative_to(ROOT)),
                                 "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
    for folder in ["heroes/detail", "heroes/actions", "heroes/guard", "heroes/guard_adjust",
                   "heroes/running", "enemies/animations", "forge/heroes"]:
        if (ROOT / "assets" / folder).exists():
            errors.append(f"retired animation directory still exists: {folder}")
    report = {"heroes": len(catalog["heroes"]), "enemy_models": len(catalog["enemies"]),
              "drawings": len(drawings), "errors": errors, "resources": drawings}
    (ROOT / "artifacts/static_combat_audit").mkdir(parents=True, exist_ok=True)
    (ROOT / "artifacts/static_combat_audit/audit.json").write_text(json.dumps(report, indent=2) + "\n")
    print(f"STATIC COMBAT: {len(drawings)} drawings / {len(errors)} errors")
    for error in errors:
        print(error)
    return bool(errors)


if __name__ == "__main__":
    raise SystemExit(audit())
