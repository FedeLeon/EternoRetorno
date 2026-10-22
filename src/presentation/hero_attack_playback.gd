extends RefCounted
## Start the authored action and synchronize its contact/return with the foreground.
static func contact(ui: Control, actor: Control, hero: String, action: String, card: Dictionary, cut_in: Control = null) -> int:
	var revision: int = actor.begin_action(action)
	hold_until_finished(actor, revision, cut_in)
	if actor.has_method("contact_delay") and actor.contact_delay() > 0:
		await ui.get_tree().create_timer(actor.contact_delay()).timeout
	preload("res://src/audio/battle_audio.gd").hero(ui.audio,hero,"attack",card)
	return revision

static func hold_until_finished(actor: Control, revision: int, cut_in: Control) -> void:
	if not is_instance_valid(cut_in): return
	var release = func():
		if is_instance_valid(actor) and actor.acting: actor.finish_action(revision)
	if cut_in.completed:
		release.call()
	else:
		cut_in.finished.connect(release, CONNECT_ONE_SHOT)
		# Also release if navigation removes the foreground before normal completion.
		cut_in.tree_exiting.connect(release, CONNECT_ONE_SHOT)

static func recover(_ui: Control, actor: Control, revision: int, cut_in: Control = null) -> void:
	if is_instance_valid(cut_in) and cut_in.is_inside_tree():
		await cut_in.tree_exited
	if is_instance_valid(actor) and actor.action_revision == revision and actor.has_method("presentation_remaining"):
		var remaining: float = actor.presentation_remaining()
		if remaining > 0: await actor.get_tree().create_timer(remaining).timeout
	if is_instance_valid(actor): actor.finish_action(revision)
