"""Stage the new fiction without changing saved IDs, statistics or active content."""
from pathlib import Path
import json
from plan_postapocalyptic_art import MACHINES

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/art_direction/postapocalyptic/catalogs'
CARD_NAMES={
 'warrior_slash':'Corte de sierra','warrior_guard':'Mango reforzado','warrior_heavy':'Golpe de taller','warrior_charge':'Abrir paso','warrior_echo':'Marca de corte','warrior_pommel':'Golpe de mango','warrior_brace':'Apoyo firme','warrior_cleave':'Barrido de sierra','warrior_riposte':'Respuesta de oficio','warrior_execution':'Punto de fractura','warrior_onslaught':'Trabajo a destajo','warrior_blood_oath':'Horas extra','warrior_fortress':'Refuerzo de emergencia','warrior_rift':'Corte transversal','warrior_final_edge':'Última pasada','warrior_rally':'Entre vecinos','warrior_second_wind':'Pausa de taller','warrior_crush_armor':'Separar placas','warrior_disarm':'Trabar engranajes','warrior_prepared':'Medir y cortar','warrior_interrupt':'Cuña de madera','warrior_risk':'Sin descanso',
 'guardian_bash':'Golpe de chapa','guardian_guard':'Mampara','guardian_wall':'Pared de obra','guardian_strike':'Rebote de chapa','guardian_echo':'Refuerzo permanente','guardian_tap':'Empuje','guardian_shelter':'Cobertura','guardian_iron_chain':'Cable de sujeción','guardian_circle':'Perímetro seguro','guardian_sentinel':'Turno de vigilancia','guardian_ram':'Palanca de obra','guardian_sanctuary':'Refugio móvil','guardian_reprisal':'Devolución','guardian_aegis':'Barrera compartida','guardian_unbroken':'La estructura aguanta','guardian_lay_hands':'Primeros auxilios','guardian_inspire':'Apoyo mutuo','guardian_shield_break':'Chapa contra chapa','guardian_rebuke':'Frenar el avance','guardian_prepared':'Carga de demolición','guardian_interrupt':'Traba de seguridad','guardian_risk':'Chapa al límite',
 'rogue_cut':'Corte utilitario','rogue_dodge':'Paso lateral','rogue_toxin':'Hoja corrosiva','rogue_venom':'Ácido concentrado','rogue_echo':'Oxidación persistente','rogue_nick':'Incisión','rogue_cover':'Bajo cobertura','rogue_double_fang':'Doble corte','rogue_toxic_mist':'Aerosol corrosivo','rogue_venom_dance':'Dosificación','rogue_plague':'Fuga química','rogue_assassin':'Punto de unión','rogue_dark_cloak':'Bajo la lona','rogue_black_blood':'Contaminación','rogue_silent_end':'Desconexión silenciosa','rogue_enervating':'Disolvente','rogue_corrosive':'Ácido de batería','rogue_adrenaline':'Adrenalina','rogue_exposed':'Junta expuesta','rogue_prepared':'Dosis preparada','rogue_interrupt':'Cortar el cable','rogue_risk':'Última ampolla',
 'mage_spark':'Chispa de bobina','mage_ward':'Campo de interferencia','mage_storm':'Descarga en cadena','mage_missile':'Pulsos dirigidos','mage_echo':'Señal persistente','mage_shard':'Pulso breve','mage_veil':'Ruido de señal','mage_prism':'Doble pulso','mage_hail':'Ráfaga de impulsos','mage_comet':'Descarga focal','mage_barrage':'Barrido electromagnético','mage_starfall':'Apagón de sector','mage_mirror':'Señal reflejada','mage_nova':'Sobrecarga de bobina','mage_singularity':'Cortocircuito central','mage_focus':'Ajustar frecuencia','mage_frost_bind':'Bloqueo de servos','mage_shatter':'Aislamiento roto','mage_siphon':'Recuperar carga','mage_prepared':'Capacitor cargado','mage_interrupt':'Interrumpir señal','mage_risk':'Batería al rojo',
}
REPLACE=[('La Iglesia','El Laboratorio'),('La Herrería · Acero que perdura','El Taller · Herramientas para resistir'),('La Taller · Acero que perdura','El Taller · Herramientas para resistir'),('La Laboratorio','El Laboratorio'),('criaturas','unidades'),('unidads','unidades'),('la cripta de los ecos','la red de mantenimiento'),('el bosque de las raíces','el cinturón industrial'),('la fortaleza del último fuego','la Central del Reinicio'),('El bosque mantiene atrapado','La red de contención mantiene atrapado'),('Mazmorra 1 · Cripta','Zona 1 · Mantenimiento'),('Mazmorra 2 · Bosque','Zona 2 · Industria'),('Mazmorra 3 · Fortaleza volcánica','Zona 3 · Central del Reinicio'),('La cripta de los ecos','Red de mantenimiento'),('El Bosque de las Raíces','Cinturón industrial'),('Fortaleza del Último Fuego','Central del Reinicio'),('Entrar al bosque','Entrar al cinturón'),('Bajar por la escalera','Avanzar de sector'),('Iglesia','Laboratorio'),('iglesia','laboratorio'),('Herrería','Taller'),('herrería','taller'),('almas','celdas'),('Almas','Celdas'),('reliquias','componentes'),('Reliquias','Componentes'),('reliquia','componente'),('Reliquia','Componente'),('veneno','corrosión'),('Veneno','Corrosión'),('magia','interferencia'),('arcano','electromagnético'),('arcana','electromagnética'),('criatura','unidad'),('espadazo','corte'),('espada','herramienta'),('armaduras','protecciones'),('armadura','protección'),('runa','circuito'),('conjuros','señales'),('conjuro','señal'),('mágico','eléctrico'),('mágica','eléctrica'),('hechizo','pulso'),('Hechizo','Pulso'),('bastón','emisor'),('poción','ampolla'),('Poción','Ampolla'),('maldiciones','averías'),('maldición','avería'),('bendición','ajuste'),('bendiciones','ajustes')]
TEXT_FIELDS={'name','title','description','text','choices','role','lore','hook','before','camp_work','forced_to_fight','personality','flaw','fear','desire','arc','voice','everyday_detail','visual','premise','first_crisis','cost','camp','cards','occupation','status','color'}

def words(s):
    for old,new in REPLACE:s=s.replace(old,new)
    for old,new in [('El corrosión','La corrosión'),('el corrosión','la corrosión'),('las componentes','los componentes'),('Las componentes','Los componentes'),('una componente','un componente'),('Una componente','Un componente'),('la componente','el componente'),('La componente','El componente'),('componente exclusiva','componente exclusivo'),('componente aleatoria','componente aleatorio')]:s=s.replace(old,new)
    return s

def translate(node,field=''):
    if isinstance(node,dict):return {k:translate(v,k) for k,v in node.items()}
    if isinstance(node,list):return [translate(v,field) for v in node]
    if isinstance(node,str) and field in TEXT_FIELDS:return words(node)
    return node

def stage():
    OUT.mkdir(parents=True,exist_ok=True)
    docs={p.stem:translate(json.loads(p.read_text())) for p in (ROOT/'data').glob('*.json')}
    for key in ['content','crypt_enemies','forest_enemies','enemy_expansion','adventure_enemies','cinematic_enemies','polish_enemies']:
        enemies=docs[key]['enemies'] if key=='content' else docs[key]
        for id,e in enemies.items():
            e['name']=MACHINES[e['visual']][0]+(' · reforzada' if id=='ash_brute_elite' else '')
    for key in ['content','support_cards','tactical_cards','risk_cards']:
        cards=docs[key]['cards'] if key=='content' else docs[key]
        for id,c in cards.items():c['name']=CARD_NAMES[id]
    for id,h in docs['content']['heroes'].items():
        h['lore']='Un vecino del refugio. Herramientas recuperadas contra la máquina.'
        h['color']={'warrior':'bd6be1','guardian':'f0a657','rogue':'69caa5','mage':'75d8e6'}[id]
    world=docs['hero_lives']['world']
    world.update(premise='La red ARCA reinicia cada día los sectores de una ciudad arruinada. Entre sus puntos ciegos, un refugio de vecinos conserva reparaciones, cuadernos y recuerdos.',first_crisis='Los convoyes automáticos ya no entregan provisiones: clasifican a los supervivientes como intrusos. Cuatro vecinos salen a recuperar suministros y encontrar el núcleo que sostiene el ciclo.',camp='El refugio funciona porque cada persona sigue trabajando: se reparan techos, se curan heridas y se enseña a quienes todavía no saben leer. Ningún protagonista deja de ser vecino por aprender a luchar.',cards='El cuaderno común conserva técnicas y errores que la red no consigue borrar. Las cartas representan decisiones aprendidas entre compañeros; la ficción no cambia las reglas del mazo.')
    lives=docs['hero_lives']['heroes']
    lives['warrior'].update(hook='Nicolás reparaba puertas. Salió a buscar el convoy con una hoja de sierra adaptada y sigue guardando clavos doblados.',visual='Camisa violeta, delantal gastado, botas de trabajo, barba corta y sierra industrial montada sobre un mango reparado. Sin casco ni armadura militar.')
    lives['guardian'].update(hook='Inés levantaba muros. Su primera defensa fue una señal de chapa contra los drones que entraban al barrio.',visual='Trenza pelirroja, chaqueta de obra naranja, tiza en el cinturón, escudo de señalización reparado y palanca. Sin armadura medieval.')
    lives['rogue'].update(hook='Mauro preparaba remedios. Ahora dosifica también ácidos capaces de corroer las juntas de una máquina.',visual='Rostro completo visible sin máscara, pelo oscuro desordenado, chaqueta verde petróleo, botiquín, cuchillos utilitarios y frascos bien separados.')
    lives['mage'].update(hook='Vera enseñaba a leer. Encontró un patrón en los reinicios y armó un emisor con una antena rota y una batería.',forced_to_fight='Comparó los horarios de patrulla y las señales que precedían a cada reinicio. Un aparato recuperado respondía a esas frecuencias. Quemó dos fusibles antes de conseguir que un dron se detuviera.',visual='Pelo corto gris plateado, abrigo violeta, lápiz detrás de la oreja, cuaderno y emisor electromagnético de antena y cables. Sin bastón mágico ni túnica.')
    events=docs['content']['events']
    events['well'].update(name='El purificador',text='El filtro todavía funciona. Nicolás revisa la carcasa mientras Mauro comprueba el agua: parece segura.')
    events['altar'].update(name='Terminal de emergencia',text='La batería sigue conectada a un circuito dañado. Se puede recuperar una técnica del archivo, pero la descarga va a doler.',choices=['Forzar el terminal · perder 5 de vida ambos y mejorar una carta al azar','Dejar el terminal'])
    events['library'].update(name='El archivo escolar',text='Entre los cuadernos aparece un plano del sector. Alguien anotó sus errores para que el siguiente grupo no los repita.')
    adv=docs['adventure_events']
    adv['forest_spirit'].update(name='El terminal botánico',text='El viejo terminal marca un depósito de suministros. Mauro reconoce las plantas que han crecido alrededor.')
    adv['forest_spring']['name']='El colector de lluvia'
    adv['forge_altar'].update(name='Banco de recuperación',text='Un terminal de mantenimiento puede reconstruir una carta de su héroe, de coste 0–1 y mejorada. El resultado es incierto.')
    adv['ash_archive']['name']='Registro de la central'
    adv['lava_bridge']['name']='Pasarela de refrigeración'
    pairs=docs['polish_events']
    pairs['pair_guardian_warrior']['text']='Inés sujeta la chapa mientras Nicolás ajusta el mango de la sierra. Antes de salir prueban las señales que van a usar.'
    pairs['pair_mage_warrior'].update(name='Herramienta conectada',text='Vera conecta un cable aislado al mango de Nicolás. Le explica dónde no debe poner los dedos.')
    pairs['pair_guardian_mage']['text']='Vera atornilla un aislante detrás del escudo de Inés. Lo prueban con una batería casi agotada.'
    pairs['pair_mage_rogue'].update(name='Química y corriente',text='Mauro separa los frascos antes de que Vera encienda el emisor. Los dos han aprendido a avisar primero.')
    for id in ['pact_blood','pact_burden','pact_scar']:pairs[id].update(name='Recuperación arriesgada',text='Un componente útil a cambio de aceptar una avería durante la expedición.')
    dialogue=docs['camp_dialogue']
    dialogue['market']=['Mirá las conexiones antes de pagar.','No abras el frasco junto a la batería.','Si vuelve el convoy, guardame un filtro.','Te cambio filtros por vendas limpias.','Esa batería está probada. La otra, todavía no.']
    dialogue['forge']=['Dejá la pieza sobre la mesa. Todavía quema.','Eso aguanta otra salida. Dos no te prometo.','Traé también el mango. No arreglo solo la hoja.','Si apretás de más, partís la rosca.','Mientras arreglo esto, tomá un poco de agua.']
    dialogue['church']=['El aparato ayuda. Entenderlo ayuda más.','Probalo con poca carga primero.','Lo que aprendas, anotáselo al siguiente.','El cable azul. El otro ya lo quemé.','Acá anotamos también lo que sale mal.']
    dialogue['expeditions']=['El sector está cambiando. Revisen la ruta.','Un encargo por salida. Vuelvan los dos.','La radio se corta cerca de la central.','Si perdés la señal, seguí tus propias marcas.','Nos quedan dos radios que no chisporrotean.']
    effects=docs['battle_effects']
    relic_names={'ember':'Acumulador térmico','fang':'Diente de sierra','chalice':'Kit de recuperación','hourglass':'Reloj de señal','ancient_cog':'Engranaje de retorno','blood_ruby':'Sensor cardíaco','dawn_bell':'Avisador de turno','drill_tusk':'Broca endurecida','duelist_seal':'Compensador manual','giant_heart':'Bomba auxiliar','iron_knot':'Amarre de acero','ivory_mirror':'Placa reflectora','oath_chain':'Cable trenzado','raven_quill':'Registro portátil','rune_chisel':'Cincel aislado','sentinel_mask':'Óptica centinela','silver_thread':'Fibra conductora','spring_seed':'Célula de reserva','star_shard':'Condensador partido','storm_drum':'Bobina de impulso','sun_spark':'Acumulador solar','titan_hammer':'Martillo de prensa','turtle_charm':'Blindaje ligero','viper_tooth':'Boquilla corrosiva','crypt_blood':'Inyector de presión','crypt_lantern':'Lámpara de emergencia','crypt_seal':'Credencial de servicio','forest_eye':'Radar de perímetro','forest_heart':'Núcleo de reciclaje','forest_thorn':'Pinza de enganche','fire_crown':'Regulador central','fire_spark':'Celda de arranque','fire_ward':'Aislante térmico'}
    for pool in [docs['content']['relics'],docs['elite_relics'],docs['boss_relics']]:
        for id,entry in pool.items():
            if id in relic_names:entry['name']=relic_names[id]
    base_names={'vital_amulet':'Monitor vital','vigor_ring':'Condensador de arranque','phoenix_idol':'Relé de emergencia','poison_fang':'Boquilla corrosiva','arcane_orb':'Bobina amplificadora','wind_boots':'Botas reforzadas','pilgrim_shield':'Placa de protección','merchant_coin':'Ficha de intercambio'}
    for id,entry in docs['equipment']['relics'].items():entry['name']=base_names[id]
    item_names={'healing_potion':'Ampolla médica','energy_flask':'Carga auxiliar','phoenix_feather':'Cartucho de reanimación','strength_tonic':'Estimulante','concentrated_poison':'Ácido concentrado','iron_skin':'Parche protector','clarity_draught':'Refrigerante','antidote':'Antídoto'}
    for id,entry in docs['equipment']['items'].items():
        if id in item_names:entry['name']=item_names[id]
    for id,title in {'roots':'Cables de sujeción','resurrection':'Intención de reactivación','embers':'Intención de sobrecarga térmica','imprisonment':'Pinza de sujeción','magic_boost':'Voltaje amplificado','weapon_boost':'Herramienta reforzada','tainted':'Fluido corrosivo','vampiric':'Recuperación de energía','source':'Capacitor','curse_blood':'Avería hidráulica','curse_burden':'Lastre averiado','curse_scar':'Aislamiento dañado'}.items():
        if id in effects:effects[id]['title']=title
    for e in effects.values():
        e['description']=e['description'].replace('raíces','cables').replace('Raíces','Cables').replace('revivir','reactivar').replace('del bosque','del cinturón').replace('brasas','sobrecarga térmica').replace('Las cables','Los cables').replace('las cables','los cables')
    effects['roots']['description']='Los cables absorben los golpes directos antes de perder vida. El número indica sus PV restantes. La corrosión los ignora.'
    # Every cinematic keeps its ID/image reference and gains the same new fiction.
    intro=docs['cinematics']['intro'];intro['title']='Lo que el reinicio no borra'
    for chapter,text in zip(intro['chapters'],['Cada mañana ARCA reinicia los sectores. Los convoyes pasan de largo; sus drones ya no reconocen a los vecinos.','En un punto ciego de la red, el refugio conserva lo reparado y lo escrito. Allí todavía se aprende a vivir juntos.','Nicolás, Inés, Mauro y Vera salen con herramientas prestadas. Buscan provisiones y una forma de detener el siguiente reinicio.']):chapter['text']=text
    endings={1:['El guardián de mantenimiento queda inmóvil. Entre el ruido de los ventiladores, por fin se escucha el agua de las tuberías.','Una compuerta de servicio conduce al cinturón industrial. Antes de avanzar, el grupo recupera una pieza que todavía funciona.'],2:['El supervisor pierde la señal y las grúas se detienen. Las plantas siguen creciendo entre los rieles.','Más allá del patio aparece la central. Desde allí llega la orden que reinicia los sectores.'],3:['ARCA deja de responder. Los dos esperan la siguiente alarma, pero solo se oye metal enfriándose.','En el refugio todavía hay techos por reparar, heridas que curar y cuadernos sin terminar. Esta vez el día puede seguir.']}
    for floor,texts in endings.items():
        key='boss_'+str(floor)
        if key in docs['cinematics']:
            for chapter,line in zip(docs['cinematics'][key]['chapters'],texts):chapter['text']=line
    for hero in ['warrior','guardian','rogue','mage']:
        cinematic=docs['cinematics']['hero_'+hero]
        cinematic['title']=lives[hero]['name']+' · '+lives[hero]['occupation']
        cinematic['chapters'][0]['text']=lives[hero]['hook']
        cinematic['chapters'][1]['text']=words(lives[hero]['desire'])+' '+lives[hero]['everyday_detail']
    for path,data in docs.items():
        original=ROOT/'data'/f'{path}.json'
        if data!=json.loads(original.read_text()):(OUT/f'{path}.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
    (OUT/'presentation_terms.json').write_text(json.dumps(dict(REPLACE),ensure_ascii=False,indent=2)+'\n')
    print('Postapocalyptic catalogs staged:',len(list(OUT.glob('*.json'))))

if __name__=='__main__':stage()
