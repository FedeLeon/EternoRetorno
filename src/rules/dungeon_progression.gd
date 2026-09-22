extends RefCounted
# Move between floors without settling the adventure or changing its permanent profile.
static func advance(run: Dictionary, rng: RandomNumberGenerator) -> void:
	run.rooms_completed = int(run.get("rooms_completed", 0)) + run.visited.size()
	run.floor = int(run.get("floor", 1)) + 1
	run.nodes = preload("res://src/dungeon.gd").create(rng, run.floor)
	run.current = -1
	run.visited = []
	run.boss_defeated = false
	run.soul_rooms = []
	run.combat = {}
	run.reward = []
	run.reward_relic = ""
	run.erase("treasure")
	run.phase = "map"
	run.log = ["El aire del bosque reemplaza al silencio de la cripta."]
