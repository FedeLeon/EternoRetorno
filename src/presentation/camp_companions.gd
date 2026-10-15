extends Node2D
## Decorative walk/sniff cycles. Visual RNG never touches the run or save.
const CELL = 192
const BASELINE = 174
var species = "dog"
var walk_bounds = Vector2(451, 488)
var ground_y = 536.0
var sprite: Sprite2D
var behavior = "walk"
var elapsed = 0.0
var animation_clock = 0.0
var remaining = 4.0
var direction = 1.0
var visual_random = RandomNumberGenerator.new()

static func attach(ui: Control) -> void:
	for id in ["dog", "cat"]:
		var pet = new()
		pet.species = id
		pet.name = "CampDog" if id == "dog" else "CampCat"
		if id == "cat":
			pet.walk_bounds = Vector2(1144, 1194)
			pet.ground_y = 393
			pet.behavior = "eat"
			pet.remaining = 6.0
			pet.direction = -1
		ui.layer.add_child(pet)

func _ready() -> void:
	visual_random.randomize()
	position = Vector2(walk_bounds.x + 12, ground_y)
	z_index = 1
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/base_camp/companions/%s.png" % species)
	sprite.hframes = 4
	sprite.vframes = 2
	var factor = 0.57 if species == "dog" else 0.42
	sprite.scale = Vector2.ONE * factor
	sprite.position.y = -(BASELINE - CELL / 2.0) * factor
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(sprite)
	update_pose()
	queue_redraw()

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	elapsed += delta
	animation_clock += delta
	remaining -= delta
	if behavior == "walk":
		position.x = clampf(position.x + direction * (10 if species == "dog" else 8) * delta, walk_bounds.x, walk_bounds.y)
		if position.x <= walk_bounds.x or position.x >= walk_bounds.y: direction *= -1
	if remaining <= 0:
		behavior = "eat" if behavior == "walk" else ("pause" if behavior == "eat" else "walk")
		remaining = visual_random.randf_range(3.5, 6) if behavior != "pause" else visual_random.randf_range(1.8, 3.2)
		animation_clock = 0
	update_pose()

func update_pose() -> void:
	sprite.flip_h = direction < 0
	if behavior == "walk": sprite.frame = int(animation_clock * 6.0) % 4
	elif behavior == "eat": sprite.frame = [4, 5, 6, 5, 6, 7][int(animation_clock * 3.5) % 6]
	else: sprite.frame = 0

func _draw() -> void:
	draw_set_transform(Vector2(0, 1), 0, Vector2(1, 0.23))
	draw_circle(Vector2.ZERO, 32 if species == "dog" else 23, Color(0.04, 0.03, 0.06, 0.26))
