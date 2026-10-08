extends RefCounted
# Navigation owns watched flags. The player only presents already committed state.
const Player = preload("res://src/presentation/cinematic_player.gd")
static func catalog() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/cinematics.json"))

static func play(ui: Control, id: String) -> void:
	if ui.has_meta("cinematic_active"): return
	var clips = catalog()
	if not clips.has(id): return
	ui.set_meta("cinematic_active",true)
	var was_busy: bool = ui.combat_busy
	ui.combat_busy = true
	ui.close_modal()
	var player = Player.new()
	player.definition = clips[id]
	ui.add_child(player)
	ui.audio.set_context(clips[id].context)
	ui.audio.play_sfx("open",-6)
	await player.finished
	if not is_instance_valid(ui): return
	ui.combat_busy = was_busy
	ui.remove_meta("cinematic_active")
	ui.audio.select_screen(ui.screen,ui.game.run,ui.return_screen)

static func enter(ui: Control) -> void:
	if ui.game.profile.get("settings",{}).get("auto_cinematics",true) and not ui.game.profile.get("cinematics_seen",{}).has("intro"):
		await play(ui,"intro")
		mark_seen(ui,"intro")
	ui.open_base_camp()

static func party(ui: Control) -> void:
	if not ui.game.profile.get("settings",{}).get("auto_cinematics",true): return
	for hero in ui.game.run.party:
		var id = "hero_"+hero
		if not ui.game.profile.get("cinematics_seen",{}).has(id):
			await play(ui,id)
			mark_seen(ui,id)

static func boss(ui: Control) -> void:
	if ui.game.run.is_empty() or ui.game.run.get("phase","") != "reward": return
	var current = int(ui.game.run.get("current",-1))
	if current < 0 or current >= ui.game.run.nodes.size() or ui.game.run.nodes[current].kind != "boss": return
	var id = "boss_%d" % int(ui.game.run.get("floor",1))
	if id in ui.game.run.get("cinematics_seen",[]): return
	# Save before presentation: resume never awards or replays a committed finale twice.
	if not ui.game.run.has("cinematics_seen"): ui.game.run.cinematics_seen = []
	ui.game.run.cinematics_seen.append(id)
	ui.game.checkpoint()
	if ui.game.profile.get("settings",{}).get("auto_cinematics",true): await play(ui,id)
	mark_seen(ui,id)

static func mark_seen(ui: Control, id: String) -> void:
	if not ui.game.profile.has("cinematics_seen"): ui.game.profile.cinematics_seen = {}
	ui.game.profile.cinematics_seen[id] = true
	ui.game.checkpoint()
