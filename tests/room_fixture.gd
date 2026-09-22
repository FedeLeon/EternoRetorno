extends RefCounted
# Arrange a particular room for rule/UI tests without assuming generated ordering.
static func enter(game: RefCounted, kind: String) -> int:
	for node in game.run.nodes:
		if node.kind != kind: continue
		game.run.phase = "map"
		game.run.boss_defeated = false
		if node.id == 0:
			game.run.current = -1
		else:
			for parent in game.run.nodes:
				if node.id in parent.next:
					game.run.current = parent.id
					break
		game.enter_node(node.id)
		return node.id
	assert(false, "Missing room kind " + kind)
	return -1
