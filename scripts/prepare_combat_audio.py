#!/usr/bin/env python3
"""Build short offline combat sounds; never synthesize or decode PCM in combat.
Requires numpy, ffmpeg. Original voice takes and licenses are kept in art_sources/audio.
"""
import hashlib
import json
import subprocess
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / 'art_sources/audio/combat_2026_10_18'
OUT = ROOT / 'assets/audio/combat'
RATE = 32000
RECORDS = []
FOLEY = {}
CATALOG = json.loads((ROOT / 'data/audio.json').read_text())


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def decode(path):
    return np.frombuffer(subprocess.check_output([
        'ffmpeg', '-v', 'error', '-i', str(path), '-ac', '1', '-ar', str(RATE),
        '-f', 'f32le', '-']), dtype='<f4').copy()


def export(key, samples, source, processing):
    samples = np.nan_to_num(samples).astype('<f4')
    samples -= samples.mean()
    peak = max(float(np.max(np.abs(samples))), 0.001)
    samples *= 0.70 / peak
    edge = min(160, len(samples) // 4)
    samples[:edge] *= np.linspace(0, 1, edge)
    samples[-edge:] *= np.linspace(1, 0, edge)
    path = OUT / (key + '.ogg')
    subprocess.run(['ffmpeg', '-y', '-v', 'error', '-f', 'f32le', '-ar', str(RATE),
                    '-ac', '1', '-i', '-', '-c:a', 'libvorbis', '-q:a', '4', str(path)],
                   input=samples.tobytes(), check=True)
    CATALOG['files'][key] = 'res://' + path.relative_to(ROOT).as_posix()
    RECORDS.append(dict(id=key, file=str(path.relative_to(ROOT)), sha256=digest(path),
                        seconds=round(len(samples)/RATE, 4), source=source,
                        processing=processing, license='CC0-1.0'))


def event(key, files, db=-5, cooldown=0, voice=False):
    CATALOG['events'][key] = dict(files=files, db=db, vary_pitch=not voice)
    if cooldown:
        CATALOG['events'][key]['cooldown_ms'] = cooldown


def get_enemies():
    enemies = json.loads((ROOT/'data/content.json').read_text())['enemies']
    for file in ['crypt_enemies', 'forest_enemies', 'enemy_expansion', 'adventure_enemies',
                 'cinematic_enemies', 'polish_enemies']:
        enemies.update(json.loads((ROOT/f'data/{file}.json').read_text()))
    return enemies


def mechanical(profile, action, variant):
    seed = profile['seed'] + variant * 91 + {'attack':0, 'guard':200, 'death':400}[action]
    rng = np.random.default_rng(seed)
    mass = profile['mass']
    duration = {'attack':0.48 + mass*.16, 'guard':0.31, 'death':0.75 + mass*.2}[action]
    t = np.arange(int(RATE*duration))/RATE
    noise = rng.normal(size=t.size)
    noise = np.convolve(noise, [0.15, 0.3, 0.3, 0.15, 0.1], mode='same')
    f = profile['frequency'] * (1 + variant*.055)
    phase = 2*np.pi*(f*t + (170 if action == 'attack' else -f*.36)*t*t)
    pulses = profile['pulses']
    gate = (.5 + .5*np.sin(2*np.pi*pulses*t/duration))**6
    motor = np.sin(phase)*.22 + np.sin(phase*1.48)*.07
    tail = np.exp(-t*(6 if action == 'attack' else 4))
    ring = sum(np.sin(2*np.pi*f*ratio*t)*np.exp(-t*(7+i*4))/(i+1)
               for i,ratio in enumerate([2.13, 3.78, 5.31, 7.67]))
    body = np.sin(2*np.pi*(68+mass*-18)*t)*np.exp(-t*12)*.5
    kind = profile['kind']
    if kind == 'electric':
        motor += .23*np.sin(phase*3)*gate + noise*.3*gate
    elif kind == 'pneumatic':
        motor += noise*.7*gate
    elif kind == 'rotor':
        motor += noise*.35*(.6+.4*np.sin(2*np.pi*38*t))
    else:
        motor += ring*.22*gate
    signal = motor*tail + body + ring*.12*tail
    if action == 'death':
        signal = (motor*.7 + noise*.25)*np.exp(-t*4) + ring*.25*np.exp(-t*6)
        # Falling relay ticks and final pressure release, not a monster scream.
        for offset in [.07,.19,.36]:
            local = np.maximum(0,t-offset)
            signal += (t>=offset)*noise*.22*np.exp(-local*48)
    elif action == 'guard':
        signal = ring*.6*np.exp(-t*11) + noise*.18*np.exp(-t*50)
    # Real physical contact under the motor signature gives weight to the machine.
    foley_key = 'hammer' if action == 'attack' else 'metal_clash' if action == 'guard' else 'block_2'
    contact = FOLEY[foley_key]
    count = min(len(signal), len(contact))
    signal[:count] += contact[:count] * (.32 if action == 'guard' else .20)
    return signal


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for key in ['hammer', 'metal_clash', 'block_2']:
        FOLEY[key] = decode(ROOT / f'assets/audio/sfx/{key}.ogg')
    profiles = {}
    enemies = get_enemies()
    for index,(id, enemy) in enumerate(sorted(enemies.items())):
        visual = enemy['visual']
        kind = ('electric' if visual.startswith('elemental') or 'shaman' in visual else
                'rotor' if visual.startswith('flying') or any(s in id for s in ['bat','raven','wasp']) else
                'pneumatic' if any(s in id for s in ['slime','toad','miasma','bomb']) else 'servo')
        profile = dict(name=enemy['name'], visual=visual, kind=kind,
                       seed=18000+index*71, frequency=95+(index*67)%520,
                       pulses=2+index%5, mass=min(1.7,float(enemy['hp'])/85))
        profiles[id] = profile
        for action in ['attack','guard','death']:
            keys = []
            for variant in range(2 if action == 'attack' else 1):
                key = f'enemy_{id}_{action}_{variant}'
                export(key, mechanical(profile,action,variant),
                       {'type':'original mechanical design + CC0 foley', 'profile':id, 'foley':['hammer','metal_clash','block_2'], 'provenance':'art_sources/audio/sources.json'},
                       'seeded motor, inharmonic metal modes, air/noise pulses; mono 32kHz Vorbis; peak -3dB')
                keys.append(key)
            event(f'enemy_{id}_{action}',keys,-6 if action != 'death' else -8,160 if action=='guard' else 0)
    # Metal impacts combine licensed real foley with damped steel resonances.
    for i in range(4):
        source = ROOT/f'assets/audio/sfx/{["metal_clash","metal_clash_2","block","block_2"][i]}.ogg'
        base = decode(source)[:int(RATE*.6)]
        t = np.arange(max(len(base),int(RATE*.58)))/RATE
        sound = np.pad(base,(0,len(t)-len(base)))
        for ratio in [1, 1.83, 2.71, 4.09]:
            sound += .12*np.sin(2*np.pi*(690+i*127)*ratio*t)*np.exp(-t*(11+ratio))
        export(f'steel_clash_{i}',sound,{'file':str(source.relative_to(ROOT)), 'sha256':digest(source),
               'provenance':'art_sources/audio/sources.json'},'real metal hit + short inharmonic ringing; peak -3dB')
    event('shield_impact',[f'steel_clash_{i}' for i in range(4)],-3)
    event('machine_impact',['hammer','steel_clash_2','steel_clash_3'],-6)
    # Distinct performance takes: two male source performers; female takes shared
    # between Mara and Alma. No synthetic speech, no cloned actor voices.
    female_segments = [(0.43,1.19),(2.03,2.78),(3.65,4.20),(4.90,6.18),
                       (7.28,8.17),(9.32,10.37),(11.62,12.63)]
    male_root = DOC/'sources'
    male = {
        'warrior':{'attack':['3grunt1.wav','3grunt2.wav'], 'defense':['3grunt3.wav','3grunt4.wav'],
                   'hurt':['3grunt5.wav','3grunt6.wav']},
        'rogue':{'attack':['2yell1.wav','2yell3.wav'], 'defense':['2yell10.wav','2yell2.wav'],
                 'hurt':['2yell5.wav','2yell9.wav']}}
    female_indices = {'guardian':{'attack':[0,1], 'defense':[2,4], 'hurt':[5,6]},
                      'mage':{'attack':[2,4], 'defense':[0,1], 'hurt':[3,5]}}
    for hero in ['warrior','guardian','rogue','mage']:
        for action in ['attack','defense','hurt']:
            keys = []
            for variant in range(2):
                if hero in male:
                    source = male_root/male[hero][action][variant]
                    samples = decode(source)
                    # Trim leading/trailing silence, retaining breath attack and release.
                    active = np.flatnonzero(np.abs(samples)>.014)
                    if len(active): samples = samples[max(0,active[0]-1000):min(len(samples),active[-1]+1800)]
                    source_info = {'file':str(source.relative_to(ROOT)), 'sha256':digest(source), 'author':'HaelDB',
                                   'page':'https://opengameart.org/content/male-gruntyelling-sounds'}
                else:
                    source = male_root/'female.ogg'
                    start,end = female_segments[female_indices[hero][action][variant]]
                    samples = decode(source)[int(start*RATE):int(end*RATE)]
                    source_info = {'file':str(source.relative_to(ROOT)), 'sha256':digest(source), 'start':start, 'end':end,
                                   'author':'Nocturnal_Vanguard / AuraVoice',
                                   'page':'https://opengameart.org/content/female-hurt-grunts-groans'}
                key = f'voice_{hero}_{action}_{variant}'
                export(key,samples,source_info,'trim, mono 32kHz Vorbis; 5ms fades; peak -3dB; original pitch')
                keys.append(key)
            event(f'voice_{hero}_{action}',keys,-8,450,True)
            CATALOG['events'][f'voice_{hero}_{action}']['voice_group'] = hero
    (ROOT/'data/battle_audio.json').write_text(json.dumps({'enemies':profiles},ensure_ascii=False,indent=2)+'\n')
    (ROOT/'data/audio.json').write_text(json.dumps(CATALOG,ensure_ascii=False,indent=2)+'\n')
    (DOC/'sources.json').write_text(json.dumps(RECORDS,ensure_ascii=False,indent=2)+'\n')
    print(f'{len(RECORDS)} clips built for {len(profiles)} enemies and four heroes')

if __name__ == '__main__':
    main()
