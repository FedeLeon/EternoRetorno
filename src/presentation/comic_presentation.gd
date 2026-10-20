extends Node
## Decorates newly composed icons once; no per-frame tree scan or image readback.
const Outline = preload("res://src/presentation/comic_outline.gd")
const PREFIXES = ["heroes/","enemies/","warrior/","guardian/","rogue/","mage/","equipment/","forge/badges/","battle_effects/","relics/","objects/","synergies/","run_setup/","collection/icons/","collection/ui/","collection/unlocks/","map/sidebar/","map/comic/","map/minimal/","ui/"]
var host: Control

func watch(owner_ui: Control) -> void:
	host = owner_ui
	get_tree().node_added.connect(_node_added)

func _node_added(node: Node) -> void:
	if node is TextureRect and host.is_ancestor_of(node): _decorate.call_deferred(weakref(node))

func _decorate(reference: WeakRef) -> void:
	var picture = reference.get_ref() as TextureRect
	if picture == null or picture.is_queued_for_deletion() or picture.texture == null: return
	if Outline.is_baked(picture.texture) and picture.material == null: return
	if picture.material != null:
		if picture.material is ShaderMaterial and picture.material.shader.resource_path in ["res://assets/shaders/firelight.gdshader","res://assets/ui/shaders/energy_cell_flow.gdshader"]:
			Outline.configure(picture.material,picture.texture)
		return # Keep light, dissolve and energy shaders.
	var texture = picture.texture.atlas if picture.texture is AtlasTexture else picture.texture
	var path = texture.resource_path.trim_prefix("res://assets/")
	if path.begins_with("ui/numbers/") or path.begins_with("ui/polished/"): return
	if path in ["map/minimal/parchment.png","map/minimal/room_papyrus.png"]: return
	if not PREFIXES.any(func(prefix): return path.begins_with(prefix)): return
	picture.material = Outline.material_for(picture.texture)

static func frame_screen(ui: Control) -> void:
	if ui.screen not in ["home","cinematics","combat","paths","map","room","event_cards","reward","boss_reward","base_camp","select","victory","defeat","market","merchant","forge","church","refuge","expeditions","equipment","items","collection","options","training_setup"]: return
	var panel = preload("res://src/presentation/comic_panel.gd").new()
	panel.name = "ComicPageMargin"
	panel.z_index = 8
	panel.floor_number = int(ui.game.run.get("floor",1))
	var top = 0 if ui.screen in ["home","cinematics","paths"] or ui.layer.has_node("EncounterScreen") else 64
	for header_name in ["PreparationHeader", "MarketHeader"]:
		var header = ui.layer.get_node_or_null(header_name)
		if header != null: top = roundi(header.get_rect().end.y)
	ui.rect(panel,0,top,1280,720-top)
