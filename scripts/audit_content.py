"""Validate declarative content and resource references without loading saves.

Run before Godot regressions. Duplicate JSON keys and expansion IDs are errors;
merge order matches ERContent. Dynamic enemy/art paths are checked explicitly.
"""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPANSIONS = {
    'cards': ['risk_cards', 'tactical_cards', 'support_cards'],
    'enemies': ['crypt_enemies', 'forest_enemies', 'enemy_expansion',
                'adventure_enemies', 'cinematic_enemies', 'polish_enemies'],
    'relics': ['boss_relics', 'elite_relics'],
    'events': ['polish_events', 'travel_events', 'adventure_events'],
}


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f'duplicate JSON key: {key}')
        result[key] = value
    return result


def load_documents(root=ROOT):
    documents, errors = {}, []
    for path in sorted((root / 'data').glob('*.json')):
        try:
            documents[path.stem] = json.loads(path.read_text(), object_pairs_hook=unique_object)
        except (ValueError, OSError) as error:
            errors.append(f'{path.name}: {error}')
    return documents, errors


def validate(documents, root=ROOT):
    errors = []
    checks = 0

    def check(condition, message):
        nonlocal checks
        checks += 1
        if not condition:
            errors.append(message)

    def resources(value, location):
        if isinstance(value, dict):
            for key, child in value.items():
                resources(child, f'{location}.{key}')
        elif isinstance(value, list):
            for index, child in enumerate(value):
                resources(child, f'{location}[{index}]')
        elif isinstance(value, str) and value.startswith('res://'):
            check((root / value[6:]).is_file(), f'{location}: missing resource {value}')

    for name, value in documents.items():
        check(isinstance(value, (dict, list)), f'{name}: root must be an object/array')
        resources(value, name)
    base = documents.get('content', {})
    if not isinstance(base, dict):
        return {'checks': checks, 'errors': errors + ['content: invalid root']}
    merged = {}
    for category in ['heroes', *EXPANSIONS]:
        source = base.get(category, {})
        check(isinstance(source, dict) and bool(source), f'content.{category}: empty/invalid catalogue')
        merged[category] = dict(source) if isinstance(source, dict) else {}
        for filename in EXPANSIONS.get(category, []):
            source = documents.get(filename, {})
            check(isinstance(source, dict) and bool(source), f'{filename}: missing/invalid expansion')
            if not isinstance(source, dict):
                continue
            for key, value in source.items():
                check(key not in merged[category], f'{filename}: duplicate {category} ID {key}')
                merged[category].setdefault(key, value)
    heroes, cards, enemies, events = (merged[key] for key in ['heroes', 'cards', 'enemies', 'events'])
    for hero, data in heroes.items():
        check(data.get('hp', 0) > 0, f'{hero}: invalid base HP')
        for card in data.get('starter', []):
            check(card in cards and cards[card].get('owner') == hero, f'{hero}: invalid starter {card}')
    art = documents.get('card_art', {})
    targets = {'self', 'enemy', 'ally', 'all_allies', 'all_enemies'}
    for card, data in cards.items():
        check(data.get('owner') in heroes, f'{card}: unknown owner')
        check(data.get('target') in targets, f'{card}: unknown target')
        check(data.get('cost', -1) >= 0, f'{card}: invalid cost')
        check(data.get('hits', 0) >= 1, f'{card}: invalid hit count')
        check(card in art, f'{card}: missing art mapping')
    visuals = documents.get('enemy_visuals', {})
    for enemy, data in enemies.items():
        check(data.get('hp', 0) > 0, f'{enemy}: invalid HP')
        check(bool(data.get('pattern')), f'{enemy}: empty intent pattern')
        visual = data.get('visual', '')
        check(visual in visuals, f'{enemy}: unknown visual {visual}')
        for path in [f'assets/combat_static/enemies/{visual}/idle.png', f'assets/comic/enemies/{visual}.png']:
            check((root / path).is_file(), f'{enemy}: missing dynamic asset {path}')
    for floor, data in documents.get('dungeons', {}).items():
        pool = data.get('common', [])
        check(len(pool) == len(set(pool)), f'floor {floor}: repeated common enemy')
        for enemy in pool + [data.get('elite'), data.get('boss'), data.get('escort')]:
            check(enemy in enemies, f'floor {floor}: unknown enemy {enemy}')
        for event in data.get('events', []):
            check(event in events, f'floor {floor}: unknown event {event}')
        for enemy in data.get('min_stage', {}):
            check(enemy in pool, f'floor {floor}: debut outside common pool {enemy}')
        for enemy in data.get('roles', {}):
            check(enemy in pool, f'floor {floor}: role outside common pool {enemy}')
    seen = set()
    for combo in documents.get('synergies', []):
        check(combo.get('id') not in seen, f'synergies: duplicate ID {combo.get("id")}')
        seen.add(combo.get('id'))
        for hero in combo.get('heroes', []):
            check(hero in heroes, f'{combo.get("id")}: unknown hero {hero}')
        for card in combo.get('cards', []):
            check(card in cards, f'{combo.get("id")}: unknown synergy card {card}')
    audio = documents.get('audio', {})
    files = audio.get('files', {})
    for name, data in audio.get('events', {}).items():
        check(bool(data.get('files')), f'audio.{name}: no variants')
        for key in data.get('files', []):
            check(key in files, f'audio.{name}: unknown sample {key}')
    for name, data in audio.get('contexts', {}).items():
        if data.get('music'):
            check(data['music'] in files, f'audio.{name}: unknown music {data["music"]}')
        for layer in data.get('ambience', []):
            check(layer.get('id') in files, f'audio.{name}: unknown ambience {layer.get("id")}')
    return {'checks': checks, 'errors': errors,
            'counts': {name: len(values) for name, values in merged.items()}}


def audit(root=ROOT):
    documents, errors = load_documents(root)
    if errors:
        return {'checks': 0, 'errors': errors}
    try:
        return validate(documents, root)
    except (TypeError, KeyError, AttributeError) as error:
        return {'checks': 0, 'errors': [f'invalid schema: {error}']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = audit()
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
    print(f'CONTENT AUDIT: {result["checks"]} checks / {len(result["errors"])} errors')
    for error in result['errors']:
        print(error)
    raise SystemExit(bool(result['errors']))


if __name__ == '__main__':
    main()
