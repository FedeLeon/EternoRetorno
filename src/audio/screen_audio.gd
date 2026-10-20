extends RefCounted
# Presentation context only; never mutates the adventure or profile.
static func context(screen: String, run: Dictionary, return_screen: String = "") -> String:
	if screen == "items":
		screen = run.get("phase", return_screen)
	elif screen == "deck":
		screen = return_screen
	if screen == "bestiary": return "title" if return_screen == "home" else "refuge"
	if screen in ["bonds", "training_setup"]: return "refuge"
	if screen == "boss_reward": return "reward"
	if screen == "merchant": return "market"
	if screen in ["home", "options", "collection", "cinematics"]: return "title"
	if screen in ["base_camp", "select", "equipment"]: return "camp"
	if screen in ["market", "forge", "church", "expeditions", "refuge"]: return screen
	if screen == "combat" and run.get("combat",{}).get("enemies",[]).any(func(e):return e.get("enraged",false) and e.hp>0): return "combat_phase2"
	if screen == "combat" and int(run.get("current",-1)) >= 0 and run.get("nodes",[]).size() > int(run.current) and run.nodes[int(run.current)].kind == "boss": return "combat_boss"
	if screen in ["combat","reward"] and int(run.get("floor",1)) in [2,3]:
		return screen + ("_forest" if int(run.floor) == 2 else "_volcano")
	if screen in ["combat", "reward", "victory", "defeat"]: return screen
	if screen == "room" and not run.is_empty():
		var current = int(run.get("current", -1))
		var nodes: Array = run.get("nodes", [])
		if current >= 0 and current < nodes.size() and nodes[current].kind == "rest": return "rest"
	if screen in ["map", "paths", "room", "event_cards"]:
		return "volcano" if int(run.get("floor", 1)) == 3 else ("forest" if int(run.get("floor", 1)) == 2 else "crypt")
	return ""
