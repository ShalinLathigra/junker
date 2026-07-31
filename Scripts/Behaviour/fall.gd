class_name Fall
extends State

const MAX_FALL_SPEED = 300
const GRAVITY = 980
const FALL_ACC_DURATION = 0.7

var body: CharacterBody2D
var anim: SpriteAnimator
var fall_acc_t: float
var air_shift_acc_t: float
var tick_of_next_frame: int
var frame_tick_delta: int


func is_ready(_old_line: Array[State]) -> bool:
	# if any child state is ready, then flag this one as ready
	# use super.is_ready because some child states could trigger this
	# early, i.e. jumping
	return not blackboard.get("is_grounded", true)


func init() -> void:
	body = blackboard.get("body", null)
	assert(body)
	anim = blackboard.get("sprite_animator", null)
	assert(anim)
	super.init()


func enter(_old_line: Array[State] = []) -> void:
	# fall_acc_t = 0.0
	anim.play_immediate("Fall")
	super.enter(_old_line)


func exit() -> void:
	body.velocity.y = 0.0
	fall_acc_t = 0.0


func physics_tick(delta: float) -> void:
	# Handle X velocity by input
	# if blackboard.movement_unlocked:
	# Accelerate y velocity downwards to world max fall speed
	fall_acc_t = min(fall_acc_t + delta, FALL_ACC_DURATION)

	# Apply velocity
	body.velocity.y = MAX_FALL_SPEED * _pow2(fall_acc_t / FALL_ACC_DURATION)
	super.physics_tick(delta)


func _pow2(frame_t: float) -> float:
	return frame_t * frame_t
