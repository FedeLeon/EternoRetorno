"""Extract one approved drawing per action; keep selected source cells, not atlases."""
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "art_sources/static_combat_2026_10_19"
ACTIONS = ["idle", "attack", "guard", "skill", "hurt", "death"]


def load(path):
    return json.loads((ROOT / path).read_text())


def write(path, value):
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def prepare():
    manifest = load("art_sources/art_direction/postapocalyptic/assets.json")
    comic = load("data/comic_art.json")
    saved = DOC / "extraction.json"
    records = json.loads(saved.read_text()) if saved.exists() else {}
    catalog = {"heroes": {}, "enemies": {}}
    for key, record in records.items():
        kind, name, action = key.split("/")
        catalog[kind].setdefault(name, {})
        poses = catalog[kind][name]
        source_path = record["source"]
        source = ROOT / source_path
        image = Image.open(source).convert("RGBA")
        scale = record["scale"]
        if kind == "enemies" and action == "death":
            # A fixed disabled-machine illustration, not a dissolve or rotation.
            alpha = image.getchannel("A")
            image = ImageEnhance.Brightness(ImageEnhance.Color(image).enhance(.15)).enhance(.55)
            image.putalpha(alpha)
        relative = f"assets/combat_static/{key}.png"
        target = ROOT / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        image.save(target)
        box = image.getchannel("A").point(lambda a: 255 if a > 127 else 0).getbbox()
        if not box:
            raise ValueError(f"Empty static action: {key}")
        poses[action] = {"path": f"res://{relative}", "scale": scale,
                         "anchor": [image.width / 2, box[3]],
                         "bounds": [box[0], box[1], box[2] - box[0], box[3] - box[1]]}
        provenance = records[key]
        manifest[relative] = {"source": source_path, "source_sha256": digest(source),
                              "sha256": digest(target), "style": "postapocalyptic_comic",
                              "processing": "Single selected authored drawing; disabled enemy is a fixed dark desaturated variant",
                              "origin": provenance["original_provenance"]}
        if comic.get("baked", {}).get(provenance["original_atlas"], False):
            comic["baked"][relative] = True
        if kind == "heroes":
            # New authored action stills already include their fine ivory rim;
            # older idle drawings retain the runtime outline.
            if provenance.get("outline_baked", False):
                comic["baked"][relative] = True
                manifest[relative]["outline_baked"] = True
                manifest[relative]["hero_action_hd_revision"] = provenance["original_provenance"]["hero_action_hd_revision"]
            else:
                comic.get("baked", {}).pop(relative, None)
    write("data/static_combat.json", catalog)
    write("art_sources/static_combat_2026_10_19/extraction.json", records)
    write("art_sources/art_direction/postapocalyptic/assets.json", manifest)
    write("data/comic_art.json", comic)
    print(f"STATIC COMBAT: {len(records)} individual drawings / no animation sheets")


if __name__ == "__main__":
    prepare()
