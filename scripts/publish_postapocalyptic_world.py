"""Publish staged narrative only after complete art production, preserving saved IDs."""
from pathlib import Path
import json
import shutil
import sys
from postapocalyptic_art_queue import pending
from stage_postapocalyptic_catalogs import words, TEXT_FIELDS
from audit_postapocalyptic_art import audit

ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/art_direction/postapocalyptic'

def publish():
    state=pending(1)
    if state['pending']:
        raise SystemExit(f'Art incomplete: {state["pending"]} production jobs remain; catalogs stay staged.')
    coverage=audit()
    if not coverage['complete']:raise SystemExit('Runtime art coverage incomplete; narrative remains staged.')
    for source in (DOC/'catalogs').glob('*.json'):
        if source.name=='presentation_terms.json':continue
        target=ROOT/'data'/source.name
        previous=json.loads(target.read_text());current=json.loads(source.read_text())
        # Fiction may change; no authored numeric balance value or dictionary ID may.
        def numbers(node,path=''):
            if isinstance(node,dict):
                for key,value in node.items():yield from numbers(value,path+'/'+key)
            elif isinstance(node,list):
                for index,value in enumerate(node):yield from numbers(value,path+'/'+str(index))
            elif isinstance(node,(int,float,bool)):yield path,node
        if dict(numbers(previous))!=dict(numbers(current)):
            raise ValueError('Mechanical values changed: '+source.name)
        def mechanical(node):
            if isinstance(node,dict):return {key:mechanical(value) for key,value in node.items() if key not in TEXT_FIELDS}
            if isinstance(node,list):return [mechanical(value) for value in node]
            return node
        if source.name=='camp_dialogue.json':
            if previous.keys()!=current.keys():raise ValueError('Attendant IDs changed')
        elif mechanical(previous)!=mechanical(current):
            raise ValueError('Non-presentation data changed: '+source.name)
        shutil.copyfile(source,target)
    for source in (ROOT/'src').rglob('*.gd'):
        old=source.read_text();new=words(old)
        if new!=old:source.write_text(new)
    print('Postapocalyptic world published: numeric balance preserved, IDs unchanged.')

if __name__=='__main__':publish()
