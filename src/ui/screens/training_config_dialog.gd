extends RefCounted
static func open(ui: Control, draft: Dictionary = {}) -> void:
	ui.close_modal()
	var overlay = Control.new();overlay.z_as_relative=false;overlay.z_index=200
	ui.rect(overlay,0,0,1280,720,ui);ui.overlay=overlay
	var shade=ColorRect.new();shade.color=Color(0,0,0,0.86);ui.rect(shade,0,0,1280,720,overlay)
	ui.panel(170,70,940,580,ui.GOLD,overlay)
	ui.label_at("Configurar rivales de práctica",210,90,860,52,28,ui.GOLD,overlay)
	var config: Dictionary = ui.training_config.duplicate(true) if draft.is_empty() else draft.duplicate(true)
	var ids: Array = preload("res://src/rules/training_config.gd").available(ui.game)
	var slots: Array = config.get("slots", config.get("enemies", [])).duplicate()
	while slots.size() < 3: slots.append("")
	var selectors: Array[Button] = []
	for i in range(3):
		var id: String = slots[i]
		var caption = "Rival %d · %s" % [i + 1, ui.game.content.enemies[id].name if id != "" else "Elegir rival"]
		var selector = ui.button(caption, 210, 164 + i * 58, 860, 46, func(): pass, true, overlay)
		selector.name = "ChooseRival%d" % i
		selectors.append(selector)
	var mode=OptionButton.new();mode.add_item("Patrones reales de los enemigos");mode.add_item("Intención personalizada para todos")
	mode.select(1 if config.get("mode","pattern")=="custom" else 0);ui.rect(mode,210,348,860,46,overlay)
	var damage=SpinBox.new();damage.min_value=0;damage.max_value=30;damage.value=config.get("damage",6)
	var block=SpinBox.new();block.min_value=0;block.max_value=20;block.value=config.get("block",0)
	ui.label_at("Daño",210,414,110,42,20,ui.TEXT,overlay);ui.rect(damage,328,414,136,42,overlay)
	ui.label_at("Bloqueo",500,414,110,42,20,ui.TEXT,overlay);ui.rect(block,618,414,136,42,overlay)
	var counter=CheckButton.new();counter.text="Contraataque 4";counter.button_pressed=config.get("counter",false);ui.rect(counter,780,414,290,42,overlay)
	var all=CheckButton.new();all.text="Atacar a ambos héroes";all.button_pressed=config.get("all",false);ui.rect(all,210,472,400,42,overlay)
	var snapshot = func(): return {"slots":slots.duplicate(),"mode":"custom" if mode.selected==1 else "pattern","damage":int(damage.value),"block":int(block.value),"counter":counter.button_pressed,"all":all.button_pressed}
	for i in range(3):
		selectors[i].pressed.connect(func():
			var saved: Dictionary = snapshot.call()
			preload("res://src/ui/screens/training_enemy_picker.gd").open(ui, ids, slots[i], func(id):
				saved.slots[i] = id
				open(ui, saved), func(): open(ui, saved)))
	ui.label_at("Solo aparecen enemigos descubiertos. El entrenamiento no concede premios ni modifica la aventura.",210,528,860,42,17,ui.MUTED,overlay)
	ui.button("Volver",210,580,300,44,ui.close_modal,true,overlay)
	ui.button("Aplicar",620,580,450,44,func():
		var enemies: Array=[]
		for id in slots:
			if id != "": enemies.append(id)
		ui.training_config={"enemies":enemies,"mode":"custom" if mode.selected==1 else "pattern","damage":int(damage.value),"block":int(block.value),"counter":counter.button_pressed,"all":all.button_pressed}
		ui.close_modal(),true,overlay)
