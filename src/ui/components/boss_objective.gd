extends RefCounted
static func actions(ui: Control) -> Array:
	var state: Dictionary=ui.game.run.combat.get("boss_objective",{})
	if state.is_empty(): return []
	var caption="Romper fuente · %d PV" % state.hp if state.kind=="source" else "Quebrar placa · %d" % state.hp if state.kind=="armor" else "Liberar compañero"
	var enabled=not state.broken and ui.game.run.combat.energy>=1 and (state.kind!="prison" or state.trapped>=0)
	return [{"text":caption+" · 1 energía", "id":"BossObjectiveAction", "enabled":enabled, "callback":func():
		if ui.game.polish_action("boss_objective"):
			ui.close_modal();ui.audio.play_sfx("magic");ui.render()}]
