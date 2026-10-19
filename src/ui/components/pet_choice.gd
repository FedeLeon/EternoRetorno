extends RefCounted
## Reuses the camp companions' first pose, never stretches an entire spritesheet.
const Pets = preload("res://src/rules/pet_companions.gd")

static func texture(id: String) -> Texture2D:
	var atlas = AtlasTexture.new()
	atlas.atlas = load("res://assets/base_camp/companions/%s.png" % id)
	atlas.region = Rect2(0, 0, 192, 192)
	return atlas

static func build(ui: Control, choose: Callable) -> void:
	var title = ui.label_at("Elegí quién los acompaña · Una pasiva para toda la aventura", 220, 132, 840, 28, 20, ui.TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ids = ["dog", "cat"]
	for i in range(ids.size()):
		var id = ids[i]
		var pet = Pets.definitions()[id]
		var selected = ui.selected_pet == id
		var card = ui.button("", 275 + i * 375, 172, 355, 140, func(): choose.call(id))
		card.name = "Pet_" + id
		card.tooltip_text = pet.description
		preload("res://src/ui/components/target_glow.gd").attach(card, selected)
		var art = TextureRect.new()
		art.texture = texture(id)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.rect(art, 8, 15, 108, 108, card)
		ui.label_at(("✓ " if selected else "") + pet.name + " · " + pet.passive, 120, 12, 226, 30, 19, ui.GOLD if selected else ui.TEXT, card)
		var description = ui.label_at(pet.description, 120, 47, 221, 80, 18, ui.TEXT, card)
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

static func indicator(id: String) -> Dictionary:
	if not Pets.definitions().has(id): return {}
	var pet = Pets.definitions()[id]
	return {"name":pet.name + " · " + pet.passive, "description":pet.description, "owner":"Compañía", "texture":texture(id)}
