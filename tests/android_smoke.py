#!/usr/bin/env python3
"""Drive the installed debug APK with real ADB taps; never alter its save.
Only the explicitly named test emulator is touched. Reads debug app state to
assert outcomes and choose moves; screenshots are rendered by Android.
"""
import argparse, io, json, struct, subprocess, time
from PIL import Image
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ADB=ROOT/'.tools/android/platform-tools/adb'
PACKAGE='com.eternoretorno.game'
CONTENT=json.loads((ROOT/'data/content.json').read_text())

class VariantReader:
    def __init__(self,data): self.data=data; self.pos=4
    def unpack(self,fmt):
        value=struct.unpack_from('<'+fmt,self.data,self.pos)[0]
        self.pos+=struct.calcsize('<'+fmt)
        return value
    def read(self):
        header=self.unpack('I'); tag=header&0xffff; wide=header&0x10000
        if tag==0: return None
        if tag==1: return bool(self.unpack('I'))
        if tag==2: return self.unpack('q' if wide else 'i')
        if tag==3: return self.unpack('d' if wide else 'f')
        if tag in (4,21):
            length=self.unpack('I'); text=self.data[self.pos:self.pos+length].decode('utf8')
            self.pos+=(length+3)&~3
            return text
        if tag==27:
            size=self.unpack('I')&0x7fffffff
            result={}
            for _ in range(size):
                key=self.read(); result[key]=self.read()
            return result
        if tag==28: return [self.read() for _ in range(self.unpack('I')&0x7fffffff)]
        raise ValueError(f'Unsupported variant {header:x} at {self.pos}')

class Device:
    def __init__(self,serial):
        assert serial.startswith('emulator-'), 'This runner only operates on an emulator.'
        self.prefix=[str(ADB),'-s',serial]
        self.scale=1.5; self.offset=210
    def adb(self,*args): return subprocess.check_output(self.prefix+list(args),stderr=subprocess.PIPE)
    def shell(self,*args): return self.adb('shell',*map(str,args))
    def tap(self,x,y):
        self.shell('input','tap',round(self.offset+x*self.scale),round(y*self.scale))
        time.sleep(.7)
    def state(self):
        data=self.adb('exec-out','run-as',PACKAGE,'cat','files/eterno.save')
        return VariantReader(data).read()
    def wait_state(self,predicate):
        for _ in range(40):
            state=self.state()
            if predicate(state): return state
            time.sleep(.2)
        raise AssertionError("Timed out waiting for saved state")
    def shot(self,name):
        (ROOT/'docs'/f'android-{name}.png').write_bytes(self.adb('exec-out','screencap','-p'))
    def is_home(self):
        image=Image.open(io.BytesIO(self.adb("exec-out","screencap","-p"))).convert("RGB")
        region=image.crop((297,189,1305,501))
        count=sum(r>200 and 3<r-g<25 and 5<g-b<35 for r,g,b in region.getdata())
        return count>5000
    def open_saved_screen(self):
        for _ in range(30):
            if self.is_home(): break
            time.sleep(.5)
        else: raise AssertionError("Home screen did not render")
        self.tap(240,488)
        for _ in range(30):
            if not self.is_home(): return
            time.sleep(.5)
        raise AssertionError("Continue button did not open saved screen")
    def restart(self):
        self.shell('am','force-stop',PACKAGE)
        self.shell('am','start','-n',PACKAGE+'/com.godot.game.GodotAppLauncher')
        self.open_saved_screen()
    def check_resume(self):
        before=self.state()
        self.restart()
        assert self.state()==before, 'Restart changed game state'

POSITIONS=[(86,418),(58,254),(162,315),(154,100),(315,56),(321,152),(502,102),(594,229),(485,243),(487,405),(306,384),(317,262)]
def choose_card(run):
    battle=run['combat']; best=(-1,None,None)
    for i,inst in enumerate(battle['hand']):
        c=CONTENT['cards'][inst['id']].copy()
        if inst['upgraded']:
            for k in ['damage','block','heal']:
                if c[k]>0:c[k]+=3
            if c['poison']>0:c['poison']+=2
        owner=run['party'].index(c['owner'])
        if c['cost']>battle['energy'] or run['heroes'][owner]['hp']<=0:continue
        if c['target']=='enemy':targets=[i for i,e in enumerate(battle['enemies']) if e['hp']>0]
        elif c['target']=='ally':targets=[i for i,h in enumerate(run['heroes']) if h['hp']>0]
        else:targets=[owner]
        for target in targets:
            score=(c['damage']*c['hits']+c['poison']*2)/max(1,c['cost'])
            if c['target']=='enemy':
                e=battle['enemies'][target]
                if c['damage']*c['hits']>=e['hp']+(0 if c['pierce'] else e['block']):score+=30
            if c['target']=='all_enemies':score*=sum(e['hp']>0 for e in battle['enemies'])
            if c['target'] in ['ally','self','all_allies']:
                h=run['heroes'][target]
                score+=min(c['heal'],h['max_hp']-h['hp'])*2/max(1,c['cost'])
                for e in battle['enemies']:
                    if e['hp']>0 and (e['intent']['target']==target or e['intent'].get('all') or c['target']=='all_allies'):
                        score+=min(c['block'],max(0,e['intent']['damage']-h['block']))*.8/max(1,c['cost'])
            if score>best[0]:best=(score,i,target)
    return best[1:]

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--serial',default='emulator-5554');parser.add_argument('--continue-run',action='store_true');args=parser.parse_args()
    d=Device(args.serial)
    if not args.continue_run:
        d.tap(240,488);d.tap(130,300);d.tap(946,300);d.shot('02-personajes');d.tap(1070,637)
    if args.continue_run: d.restart()
    state=d.state(); assert state['run']['phase'] in ('map','combat','reward','room')
    d.shot('03-mapa')
    resumed_combat=False;resumed_reward=False;checked_back=False
    upgraded=any(c['upgraded'] for c in state['run']['deck'])
    for step in range(500):
        state=d.state();r=state['run'];phase=r['phase']
        print(f'{step:03d}: {phase} room={r["current"]} hp={[h["hp"] for h in r["heroes"]]}',flush=True)
        if phase in ['victory','defeat']:
            d.shot('10-'+phase)
            assert phase=='victory', 'Touch-driven adventure ended in defeat'
            assert len(state['profile']['unlocked_cards'])>=2
            before=state;d.restart()
            assert d.state()==before, 'Result/unlocks duplicated after restart'
            print('PASS: full adventure, targets, cards, rooms, upgrades, rewards, victory, restart, back, background/resume',flush=True)
            return
        if phase=='map':
            if r['boss_defeated']:
                d.shot('09-escalera');d.tap(394,610);continue
            available=[0] if r['current']==-1 else r['nodes'][r['current']]['next']
            index=available[0]
            for n in available:
                if r['nodes'][n]['kind'] in ['event','rest']:index=n
                if r['nodes'][index]['kind']=='elite':index=n
            x,y=POSITIONS[index];d.tap(x+66,y+151)
        elif phase=='combat':
            if not resumed_combat:
                d.shot('04-combate');d.check_resume();resumed_combat=True
            if not checked_back:
                before=d.state()
                d.shell('input','keyevent','4');time.sleep(.3);d.shot('05-pausa');d.tap(640,502)
                assert d.state()==before,'Back changed state'
                d.shell('input','keyevent','3');time.sleep(.3)
                d.shell('am','start','-n',PACKAGE+'/com.godot.game.GodotAppLauncher')
                d.open_saved_screen()
                assert d.state()==before,'Background changed state'
                checked_back=True
            index,target=choose_card(r)
            if index is None:d.tap(1080,680)
            else:
                n=len(r['combat']['hand']);start=(1280-(n*232-14))/2
                d.tap(start+index*232+109,545)
                c=CONTENT['cards'][r['combat']['hand'][index]['id']]
                x=(875+target*234 if len(r['combat']['enemies'])>1 else 991) if c['target']=='enemy' else 182+target*234
                d.tap(x,270)
        elif phase=='reward':
            if not resumed_reward:
                d.shot('06-recompensa');d.check_resume();resumed_reward=True
            before=len(r['deck']);d.tap(640,380)
            after=d.wait_state(lambda s:s['run']['phase']=='map')['run'];assert len(after['deck'])==before+1
        elif phase=='room':
            kind=r['nodes'][r['current']]['kind']
            if kind=='treasure':d.tap(640,515)
            elif kind=='rest':
                d.shot('07-descanso')
                if not upgraded:
                    d.tap(822,454);d.shot('08-mejora');d.tap(146,240)
                    assert d.wait_state(lambda s:s['run']['phase']=='map')['run']['deck'][0]['upgraded'];upgraded=True
                else:d.tap(440,454)
            else:d.tap(620,526) # Skip events to keep the touch smoke independent of random event.
        after=d.wait_state(lambda s:s!=state)
        assert after!=state, f'No state transition after step {step} ({phase})'
    raise AssertionError('Exceeded step budget')
if __name__=='__main__':main()
