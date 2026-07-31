class_name PlayerRun
extends State

const RUN_SPEED = 16 * 5 # 16 tile width * 8 tiles

var body: CharacterBody2D
var anim: SpriteAnimator


func init() -> void:
	body = blackboard.get("body", null)
	assert(body)
	anim = blackboard.get("sprite_animator", null)
	assert(anim)
	super.init()


# Enter run if grounded and have input
func is_ready(_old_line: Array[State]) -> bool:
	var ret: bool = blackboard.get("x_input_axis", 0.0) != 0 and \
			blackboard.get("is_grounded", false)
	return ret


func enter(_old_line: Array[State] = []) -> void:
	anim.play_immediate("Run")
	super.enter(_old_line)


func physics_tick(delta: float) -> void:
	# Apply velocity
	# print(blackboard.get("x_input_axis", 0.0))
	body.velocity = RUN_SPEED * Vector2(blackboard.get("x_input_axis", 0.0), 0)
	body.move_and_slide()
	super.physics_tick(delta)
