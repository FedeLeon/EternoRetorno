extends RefCounted
# Presentation context only; never mutates the adventure or profile.
static func context(screen: String, run: Dictionary, return_screen: String = "") -> String:
	if screen == "items":
		screen = run.get("phase", return_screen)
	elif screen == "deck":
		screen = return_screen
	if screen in ["home", "options", "collection"]: return "title"
	if screen in ["base_camp", "select", "equipment"]: return "camp"
	if screen in ["market", "forge", "church", "expeditions", "refuge"]: return screen
	if screen in ["combat", "reward", "victory", "defeat"]: return screen
	if screen == "room" and not run.is_empty():
		var current = int(run.get("current", -1))
		var nodes: Array = run.get("nodes", [])
		if current >= 0 and current < nodes.size() and nodes[current].kind == "rest": return "rest"
	if screen in ["map", "room"]:
		return "forest" if int(run.get("floor", 1)) == 2 else "crypt"
	return ""
