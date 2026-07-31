extends CharacterBody2D

# blackboard
var blackboard: Dictionary
# Track reference to the state machine and animator for feeding in to nodes
var state_machine: StateMachine

@onready var sprite_animator: SpriteAnimator = %SpriteAnimator as SpriteAnimator
# also attach a config file here, this will contain stuff like 
# audio frames, etc. that we need access to elsewhere
@onready var early_ground_ray: RayCast2D = %EarlyGroundRay as RayCast2D


func _ready() -> void:
	_init_state_machine()
	blackboard.is_idle = true
	blackboard.body = self as CharacterBody2D
	blackboard.sprite_animator = sprite_animator
	state_machine.inject(blackboard)

	state_machine.init()


func _process(delta: float) -> void:
	# Update inputs
	var x_input_axis: float = Input.get_axis(
		"Left",
		"Right",
	)
	if x_input_axis != 0.0:
		# player character is by default left facing
		sprite_animator.point_towards(x_input_axis > 0, true)

	blackboard.x_input_axis = x_input_axis
	if Input.is_action_pressed("Jump"):
		blackboard.jump_input_held = true
		blackboard.tick_of_last_jump_input = Time.get_ticks_msec()
	else:
		blackboard.jump_input_held = false

	# Update state machine
	state_machine.tick(delta)


func _physics_process(delta: float) -> void:
	# Check ground
	blackboard.is_grounded = is_on_floor()
	if blackboard.is_grounded:
		blackboard.tick_of_last_ground = Time.get_ticks_msec()
	blackboard.can_jump = early_ground_ray.collide_with_bodies and early_ground_ray.get_collider() is TileMapLayer

	# Can track or add references to all sorts of state from here, then all states get access to the whole set
	# Yes it's ugly, but it's fiine

	state_machine.physics_tick(delta)


func _init_state_machine() -> void:
	state_machine = StateMachine.new()
	var ground = PlayerGround.new()
	ground.register_states([PlayerRun.new(), Idle.new()])
	var air = PlayerAir.new()
	air.register_states([PlayerJetpack.new(), Fall.new()])
	state_machine.register_states([air, ground])
