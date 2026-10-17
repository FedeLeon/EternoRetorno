extends RefCounted
## Authored guard drawings, played forward/back with fixed feet and no deformation.
const HEROES = ["warrior", "guardian", "rogue", "mage"]
var actor: Control
var phase = 0
var wait_remaining = 0.0
var elapsed = 0.0
var duration = 4.0
var moving = false
var cycles = 0

func _init(owner_actor: Control) -> void:
	actor = owner_actor
	phase = HEROES.find(actor.hero_id)
	duration = 3.8 + phase * 0.16
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
	# Reverse the same in-betweens at the ends, without a last-to-first pose jump.
	var count = sprite.sprite_frames.get_frame_count("idle")
	var steps = maxi(1, (count - 1) * 2)
	var step = mini(steps - 1, floori(elapsed / duration * steps))
	sprite.pause()
	sprite.frame = step if step < count else steps - step
	sprite.offset = Vector2.ZERO
