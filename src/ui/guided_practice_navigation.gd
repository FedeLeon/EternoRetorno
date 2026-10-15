extends RefCounted
## Reuses combat controls in a sandbox; the real adventure/RNG remains untouched.
const Lessons = preload("res://src/rules/guided_lessons.gd")
static func start(ui: Control) -> void:
	ui.close_modal()
	if ui.training_original != null: return
	ui.training_original = ui.game
	var sandbox = preload("res://src/game.gd").new("user://guided-never-saved", false)
	sandbox.profile = ui.game.profile.duplicate(true)
	sandbox.profile.tutorial_complete = true
	var party: Array = ui.game.run.party if not ui.game.run.is_empty() else ["warrior", "guardian"]
	sandbox.new_run(party, 777)
	sandbox.run.training = true
	sandbox.run.training_config = {"mode":"custom", "damage":6, "block":0}
	sandbox.run.guided_lesson = {"step":0, "turn":1, "return_screen":ui.screen}
	sandbox.run.nodes[0].encounter = ["rat"]
	sandbox.enter_node(0)
	var enemy = sandbox.run.combat.enemies[0]
	enemy.hp = 500; enemy.max_hp = 500; enemy.intent.target = 0
	Lessons.prepare(sandbox, 0)
	ui.game = sandbox; ui.screen = "combat"
	ui.selected_card = -1; ui.selected_synergy = ""
	ui.render()

static func build(ui: Control) -> void:
	var step = int(ui.game.run.guided_lesson.step)
	var panel = ui.panel(8, 2, 780, 62)
	panel.name = "GuidedLesson"
	ui.label_at("%d/5 · %s\n%s" % [step + 1, Lessons.STEPS[step][0], Lessons.STEPS[step][1]], 16, 3, 540, 58, 16, ui.TEXT, panel)
	ui.button("Terminar" if step == 4 else "Seguir", 558, 10, 100, 40, func(): next(ui), Lessons.ready(ui.game), panel).name = "LessonNext"
	ui.button("Salir", 668, 10, 94, 40, func(): finish(ui, false), true, panel)
	if not Lessons.ready(ui.game):
		ui.button("Reponer cartas" if step == 4 else "Reiniciar práctica", 530, 78, 228, 30, func():
			if step != 4:
				for hero in ui.game.run.heroes: hero.hp = hero.max_hp; hero.block = 0
				ui.game.run.combat.turn = 1
			Lessons.prepare(ui.game, 4 if step == 4 else 0)
			ui.selected_card = -1; ui.selected_synergy = ""; ui.render())

static func next(ui: Control) -> void:
	if ui.combat_busy or not Lessons.ready(ui.game): return
	var step = int(ui.game.run.guided_lesson.step)
	if step == 4: finish(ui, true); return
	Lessons.prepare(ui.game, step + 1)
	ui.selected_card = -1; ui.selected_synergy = ""; ui.render()

static func finish(ui: Control, completed: bool) -> void:
	if ui.combat_busy or ui.training_original == null: return
	var destination: String = ui.game.run.guided_lesson.return_screen
	ui.game = ui.training_original; ui.training_original = null
	ui.game.profile.tutorial_complete = true
	if completed: ui.game.profile.guided_practice_complete = true
	ui.game.checkpoint()
	ui.selected_card = -1; ui.selected_synergy = ""; ui.screen = destination; ui.render()
