class_name PlayerAir
extends State

const MAX_FALL_SPEED = 300
const MAX_AIR_SPEED = 80
const AIR_ACC_DUR = 0.75
const MIN_FRAME_DELTA = 0.2

# Dependencies
var body: CharacterBody2D
var anim: SpriteAnimator
# Internal State
var tick_of_next_frame: int
var frame_tick_delta: int


func init() -> void:
	body = blackboard.get("body", null)
	assert(body)
	anim = blackboard.get("sprite_animator", null)
	assert(anim)
	frame_tick_delta = floor(
		1000 / anim.sprite_frames.get_animation_speed("Jetpack"),
	)
	super.init()


func enter() -> void:
	tick_of_next_frame = 0
	anim.play_immediate("Jetpack")
	anim.stop()
	super.enter()


func exit() -> void:
	super.exit()
	body.velocity.y = 0.0


func get_fall_frame(body_vel: float) -> int:
	if body_vel > MAX_FALL_SPEED * 0.05:
		return (anim.frame + 1) % 4
	elif body_vel > -MAX_FALL_SPEED * 0.05:
		return 4
	elif body_vel > -MAX_FALL_SPEED * 0.8:
		return 5 + (anim.frame + 1) % 4
	else:
		return 9 + (anim.frame + 1) % 3


func tick(delta: float) -> void:
	# Check body velocity, pick frame based on velocity
	var ticks_msec: int = Time.get_ticks_msec()
	if ticks_msec >= tick_of_next_frame:
		anim.frame = get_fall_frame(body.velocity.y)
		# if delta from zero is small, then frame_tick_delta is full
		# if it's large, then it's small
		var frame_short_delta: float = lerp(
			1.0,
			MIN_FRAME_DELTA,
			abs(body.velocity.y / MAX_FALL_SPEED),
		)
		tick_of_next_frame = ticks_msec + \
				int(frame_tick_delta * frame_short_delta)
	super.tick(delta)


func physics_tick(delta: float) -> void:
	# Handle X velocity by input
	# if blackboard.movement_unlocked:
	var input_direction: float = blackboard.get("x_input_axis", 0.0)
	# Apply velocity
	body.velocity.x = MAX_AIR_SPEED * input_direction

	# Apply child state's physics behaviours
	super.physics_tick(delta)

	# Special case, handle body move and slide last
	body.move_and_slide()
