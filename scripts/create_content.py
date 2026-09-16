"""Deterministic, original prototype content; no network or generated artwork."""
import json
from pathlib import Path
classes = [
 ('warrior','Guerrero','Daño directo',58,'b65aa8','Portador Maldito.\nAcero y maldición.'),
 ('guardian','Guardiana','Protección',64,'80b4b3','Nadie cae a sus espaldas.'),
 ('rogue','Pícaro','Veneno',45,'a4be73','Hasta la piedra aprende a sangrar.'),
 ('mage','Maga','Ataques múltiples',42,'b095d4','Una chispa. Mil ecos.'),
 ('cleric','Clériga','Curación',48,'e3c887','Una luz que se niega a morir.'),
 ('ranger','Explorador','Precisión',48,'779fc1','Siempre encuentra una salida.')]
heroes={i:dict(id=i,name=n,role=r,hp=h,color=c,lore=l) for i,n,r,h,c,l in classes}
cards={}
def card(owner,key,name,cost,target,damage=0,block=0,heal=0,poison=0,hits=1,pierce=False,locked=False):
 i=owner+'_'+key
 cards[i]=dict(id=i,owner=owner,name=name,cost=cost,target=target,damage=damage,block=block,heal=heal,poison=poison,hits=hits,pierce=pierce,locked=locked)
 return i
card('warrior','slash','Tajo',1,'enemy',damage=9)
card('warrior','guard','Guardia de hierro',1,'self',block=9)
card('warrior','heavy','Golpe pesado',2,'enemy',damage=19)
card('warrior','charge','Embestida',1,'enemy',damage=7,block=4)
card('warrior','echo','Filo del retorno',2,'enemy',damage=25,locked=True)
card('guardian','bash','Golpe de escudo',1,'enemy',damage=7,block=3)
card('guardian','guard','Baluarte',1,'ally',block=12)
card('guardian','wall','Muro del alba',2,'all_allies',block=13)
card('guardian','strike','Contraataque',1,'enemy',damage=9)
card('guardian','echo','Juramento eterno',2,'all_allies',block=22,locked=True)
card('rogue','cut','Puñalada',1,'enemy',damage=8)
card('rogue','dodge','Paso sombrío',1,'self',block=8)
card('rogue','toxin','Hoja tóxica',1,'enemy',damage=4,poison=4)
card('rogue','venom','Veneno negro',2,'enemy',poison=9)
card('rogue','echo','Herida perpetua',1,'enemy',damage=6,poison=7,locked=True)
card('mage','spark','Chispas',1,'enemy',damage=4,hits=2)
card('mage','ward','Velo arcano',1,'self',block=8)
card('mage','storm','Tormenta',2,'all_enemies',damage=10)
card('mage','missile','Misiles del vacío',2,'enemy',damage=5,hits=3)
card('mage','echo','Constelación rota',2,'all_enemies',damage=7,hits=2,locked=True)
card('cleric','light','Luz cortante',1,'enemy',damage=8)
card('cleric','ward','Fe',1,'ally',block=9)
card('cleric','heal','Restauración',1,'ally',heal=7)
card('cleric','judgment','Juicio',2,'enemy',damage=14,heal=4)
card('cleric','echo','Luz del retorno',2,'all_allies',heal=12,block=5,locked=True)
card('ranger','arrow','Flecha certera',1,'enemy',damage=8,pierce=True)
card('ranger','evade','Retirada',1,'self',block=8)
card('ranger','aim','Disparo al corazón',2,'enemy',damage=19,pierce=True)
card('ranger','double','Doble disparo',1,'enemy',damage=4,hits=2)
card('ranger','echo','Último horizonte',2,'enemy',damage=26,pierce=True,locked=True)
# Expanded catalog is maintained as data; this generator also updates the starters.
original_basics = {hero: [k for k,v in cards.items() if v['owner']==hero and not v['locked']] for hero in heroes}
cards.update(json.loads(Path('data/additional_cards.json').read_text()))
for hero in heroes:
 basic = original_basics[hero]
 modest = [k for k,v in cards.items() if v['owner']==hero and v.get('tier')=='starter']
 # Ten per hero: repeated core attack/defense, plus two modest class cards.
 heroes[hero]['starter']=[basic[0]] * 4 + [basic[1]] * 4 + modest
enemies={
 'rat':dict(name='Rata de cripta',hp=22,color='b59a86',pattern=[dict(damage=6),dict(damage=8)]),
 'skeleton':dict(name='Centinela hueco',hp=30,color='d6c9a9',pattern=[dict(damage=7,block=5),dict(damage=11)]),
 'cultist':dict(name='Devoto del ciclo',hp=28,color='b58cc5',pattern=[dict(damage=6),dict(damage=9),dict(damage=13)]),
 'slime':dict(name='Lodo ancestral',hp=34,color='91b37d',pattern=[dict(damage=5,block=7),dict(damage=9)]),
 'elite':dict(name='Caballero sin tiempo',hp=78,color='bfa873',pattern=[dict(damage=12,block=8),dict(damage=9,all=True),dict(damage=18)]),
 'boss':dict(name='El Guardián del Retorno',hp=110,color='cf7666',pattern=[dict(damage=11,all=True),dict(damage=17,block=10),dict(damage=22)])}
# Visual identities retain stable encounter IDs and combat balance.
for key, visual in {'rat': 'crypt_bat', 'skeleton': 'crypt_lancer', 'cultist': 'crypt_shaman', 'slime': 'crypt_slime', 'elite': 'skeleton_6', 'boss': 'crypt_automaton'}.items():
 enemies[key]["visual"] = visual
 enemies[key]["name"] = json.loads(Path("data/enemy_visuals.json").read_text())[visual]["name"]

relics={
 'ember':dict(name='Ascua persistente',description='Al iniciar cada combate, ambos ganan 4 de bloqueo.',locked=False),
 'fang':dict(name='Colmillo de obsidiana',description='Cada impacto de tus cartas inflige 1 de daño adicional.',locked=False),
 'chalice':dict(name='Cáliz de musgo',description='Tras ganar un combate, ambos recuperan 3 de vida.',locked=False),
 'hourglass':dict(name='Reloj sin arena',description='El primer turno de cada combate tiene 1 de energía adicional.',locked=True)}
events={
 'well':dict(name='El pozo de los ecos',text='Una voz pronuncia nombres que todavía no conocés. El agua conserva un calor imposible.',choices=['Beber · recuperar 8 de vida ambos','Seguir adelante']),
 'altar':dict(name='El altar hambriento',text='Una hendidura en la piedra espera una ofrenda. Bajo ella brilla un filo intacto.',choices=['Ofrendar · perder 5 de vida ambos y mejorar una carta al azar','Dejar el altar']),
 'library':dict(name='La biblioteca hundida',text='Las páginas se deshacen salvo una: describe exactamente tu llegada a esta sala.',choices=['Leer · elegir una carta','Cerrar el libro'])}
Path('data/content.json').write_text(json.dumps(dict(heroes=heroes,cards=cards,enemies=enemies,relics=relics,events=events),ensure_ascii=False,indent=2)+'\n')
