extends State

const MAX_JUMP_SPEED: float = -100
const START_JUMP_SPEED: float = -80
const ACCEL_TICKS: int = 1000
const COYOTE_TIME_TICKS: int = 300
const JUMP_BUFFER_TICKS: int = 200

# Relevant information for the player:
var body: CharacterBody2D
var tick_of_accel_start: int
var boost_over: bool = false


# So, we want to implement:
# 	1. jump buffering for when a player wants to spam jump and hop on the ground
#		This will come with the blackboard, report time of last ground
# 	2. coyote time for when a player is a tiny bit late
# 	3. Initial jerk + upwards acceleration
func init() -> void:
	body = blackboard.get("body", null)
	assert(body)
	super.init()


# need to handle jump buffering, etc within the state
# Enter run if grounded and have input
func is_initial_jump_input_valid() -> bool:
	# If not grounded recently, then this is blocked
	var is_grounded_recently: bool = COYOTE_TIME_TICKS > \
			Time.get_ticks_msec() - blackboard.get("tick_of_last_ground", 0)
	if not is_grounded_recently:
		return false

	# Otherwise, if currently held or within buffered time, then input valid
	return blackboard.get("jump_input_held", false) or \
			blackboard.get("tick_of_last_jump_input", 0) + JUMP_BUFFER_TICKS > \
					Time.get_ticks_msec()


func is_ready() -> bool:
	return is_initial_jump_input_valid() or \
			blackboard.get("is_mid_flight", false)


func enter() -> void:
	blackboard.is_mid_flight = true
	tick_of_accel_start = Time.get_ticks_msec()
	boost_over = false


func exit() -> void:
	blackboard.is_mid_flight = false


func tick(_delta: float) -> void:
	var current_tick: int = Time.get_ticks_msec()
	var input_held: bool = blackboard.get("jump_input_held", false)
	if not boost_over and not input_held:
		boost_over = true

	if boost_over or current_tick - tick_of_accel_start >= ACCEL_TICKS:
		blackboard.is_mid_flight = false


func physics_tick(_delta: float) -> void:
	var current_tick: int = Time.get_ticks_msec()
	var elapsed: int
	elapsed = current_tick - tick_of_accel_start
	body.velocity.y = lerp(
		START_JUMP_SPEED,
		MAX_JUMP_SPEED,
		float(elapsed) / ACCEL_TICKS,
	)
