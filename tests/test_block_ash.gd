extends SceneTree
var failures = 0
func _initialize(): call_deferred("run_tests")
func check(ok: bool, message: String):
	if not ok:
		failures += 1
		printerr(message)
func run_tests():
	var stage = Control.new()
	root.add_child(stage)
	var block = preload("res://src/ui/components/block_indicator.gd").new()
	block.amount = 15
	block.overlay_number = true
	block.explanation = "Bloqueo"
	stage.add_child(block)
	block.update_active_block(8)
	check(block.visible and get_nodes_in_group("block_ash").is_empty(), "partial block remains without ashes")
	block.update_active_block(0)
	check(not block.visible and get_nodes_in_group("block_ash").size() == 1, "zero starts ashes and hides active indicator")
	block.update_active_block(0)
	check(get_nodes_in_group("block_ash").size() == 1, "zero repeated does not duplicate ashes")
	block.update_active_block(5)
	check(block.visible and block.get_child(1).value == 5, "new block survives old snapshot animation")
	await create_timer(1.5).timeout
	check(get_nodes_in_group("block_ash").is_empty() and stage.get_child_count() == 1, "effect and snapshot cleaned up")
	print("BLOCK ASH: 5 checks / %d failures" % failures)
	quit(1 if failures else 0)
