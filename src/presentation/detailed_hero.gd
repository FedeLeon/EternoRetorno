extends "res://src/presentation/static_combat_actor.gd"
## Heroes opt into authored sprite sequences individually; stills remain the fallback.
var hero_id = "warrior"
var sprite_player: Node

func _ready() -> void:
	var bank: Dictionary = Catalog.dictionary("res://data/hero_sprite_sequences.json").get(hero_id, {})
	if not bank.is_empty():
		sprite_player = preload("res://src/presentation/combat_sprite_player.gd").new()
		sprite_player.actor = self
		sprite_player.config = bank
		sprite_player.name = "CombatSpritePlayer"
		add_child(sprite_player)
		sprite_player.set_process(false)
	super._ready()

func pose_catalog() -> Dictionary:
	set_meta("hero_id",hero_id)
	set_meta("detailed",true)
	var result: Dictionary = Catalog.dictionary("res://data/static_combat.json").heroes[hero_id].duplicate(true)
	if sprite_player != null:
		var bank: Dictionary = sprite_player.config
		for action in bank.clips:
			result[action] = {"path":bank.clips[action].path,"scale":bank.clips[action].get("scale",bank.scale),"anchor":bank.anchor,"bounds":bank.clips[action].bounds}
	return result

func show_pose(action: String) -> void:
	super.show_pose(action)
	if sprite_player != null:
		sprite_player.select(current_action)
		apply_gear(gear)

func body_rect() -> Rect2:
	if sprite_player == null or sprite_player.clip.is_empty(): return super.body_rect()
	var area: Rect2 = sprite_player.bounds()
	return Rect2(sprite.position + area.position * sprite.scale, area.size * sprite.scale)

func contact_delay() -> float:
	if sprite_player == null or sprite_player.clip.is_empty(): return 0.0
	var clip: Dictionary = sprite_player.clip
	return float(clip.get("contact", 0.0)) * float(clip.duration)

func presentation_remaining() -> float:
	if sprite_player == null or sprite_player.clip.is_empty() or current_action == "idle": return 0.0
	return maxf(0.0, float(sprite_player.clip.duration) - sprite_player.elapsed)

func set_fallen(value: bool) -> void:
	super.set_fallen(value)
	if value and sprite_player != null and not sprite_player.clip.is_empty():
		sprite_player.show_frame(sprite_player.clip.frames.size() - 1)
		sprite_player.set_process(false)

func play_once(action: String) -> void:
	if sprite_player == null or not sprite_player.config.clips.has(canonical(action)):
		await super.play_once(action)
		return
	var revision = begin_action(action)
	if revision < 0 or current_action == "idle": return
	await get_tree().create_timer(float(sprite_player.clip.duration)).timeout
	if revision != action_revision: return
	if fallen: acting = false
	else: finish_action(revision)
