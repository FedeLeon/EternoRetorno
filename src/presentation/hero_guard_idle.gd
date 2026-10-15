extends RefCounted
## Continuous authored breathing/guard loop. Never deforms the body or uses game RNG.
const Grounding = preload("res://src/presentation/hero_grounding.gd")
const HEROES = ["warrior", "guardian", "rogue", "mage"]
var actor: Control
var phase = 0
var wait_remaining = 0.0
var elapsed = 0.0
var duration = 2.4
var moving = false
var cycles = 0

func _init(owner_actor: Control) -> void:
	actor = owner_actor
	phase = HEROES.find(actor.hero_id)
	duration = 2.4 + phase * 0.17
	interrupt()

func interrupt() -> void:
	moving = false
	elapsed = 0.0
	wait_remaining = 0.12 + phase * 0.07
	actor.sprite.offset = Vector2.ZERO

func advance(delta: float) -> void:
	var sprite: AnimatedSprite2D = actor.sprite
	if actor.fallen or sprite.animation != "idle" or not actor.is_visible_in_tree():
		interrupt()
		return
	if not moving:
		wait_remaining -= delta
		if wait_remaining > 0: return
		moving = true
		elapsed = -wait_remaining
	else: elapsed += delta
	while elapsed >= duration:
		elapsed -= duration
		cycles += 1
	var frame = mini(11, int(elapsed / duration * 12.0))
	if sprite.frame != frame:
		actor._blend_pose(0.12)
		sprite.pause()
		sprite.frame = frame
	var base = sprite.sprite_frames.get_frame_texture("idle", 0)
	var current = sprite.sprite_frames.get_frame_texture("idle", frame)
	sprite.offset.y = Grounding.bottom(base) - Grounding.bottom(current)
