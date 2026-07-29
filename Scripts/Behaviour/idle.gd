extends State

var sprite_animator: SpriteAnimator
var body: CharacterBody2D


func init() -> void:
	body = blackboard.get("body", null)
	assert(body)
	sprite_animator = blackboard.get("sprite_animator", null)
	assert(sprite_animator)
	super.init()


func is_ready() -> bool:
	return blackboard.get("is_idle", false) and blackboard.get("is_grounded", true)


func exit() -> void:
	super.exit()


func enter() -> void:
	sprite_animator.play_immediate("Idle")
	body.velocity = Vector2.ZERO
	super.enter()
