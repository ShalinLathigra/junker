class_name PlayerJetpack
extends State

const MIN_JETPACK_DB: float = -32.0
const MAX_JETPACK_DB: float = -24.0
const JUMP_DB: float = -22.0
const MAX_JUMP_SPEED: float = -100
const START_JUMP_SPEED: float = -80
const ACCEL_TICKS: int = 1000
const MIN_ACCEL_TICKS: int = 250
const COYOTE_TIME_TICKS: int = 300
const JUMP_BUFFER_TICKS: int = 200
const JUMP_AUDIO_RESOURCE_PATH: StringName = "res://Assets/jump3.ogg"
const JETPACK_AUDIO_RESOURCE_PATH: StringName = "res://Assets/engine5.ogg"

# Relevant information for the player:
var body: CharacterBody2D
var tick_of_accel_start: int
var boost_over: bool = false
var jump_player: AudioStreamPlayer
var jetpack_player: AudioStreamPlayer


# So, we want to implement:
# 	1. jump buffering for when a player wants to spam jump and hop on the ground
#		This will come with the blackboard, report time of last ground
# 	2. coyote time for when a player is a tiny bit late
# 	3. Initial jerk + upwards acceleration
func init() -> void:
	# Fetch body
	body = blackboard.get("body", null)
	assert(body)
	# Configure players
	jump_player = AudioManager.request_audio_player()
	jetpack_player = AudioManager.request_audio_player()
	AudioManager.use_stream(
		jump_player,
		load(JUMP_AUDIO_RESOURCE_PATH),
		JUMP_DB,
	)
	AudioManager.use_stream(
		jetpack_player,
		load(JETPACK_AUDIO_RESOURCE_PATH),
	)
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


func is_ready(_old_line: Array[State]) -> bool:
	return is_initial_jump_input_valid() or \
			blackboard.get("is_mid_flight", false)


func enter(_old_line: Array[State] = []) -> void:
	blackboard.is_mid_flight = true
	tick_of_accel_start = Time.get_ticks_msec()
	boost_over = false
	jump_player.play()
	jetpack_player.play()
	super.enter(_old_line)


func exit() -> void:
	blackboard.is_mid_flight = false
	jump_player.stop()
	jetpack_player.stop()


func tick(_delta: float) -> void:
	var current_tick: int = Time.get_ticks_msec()
	var input_held: bool = blackboard.get("jump_input_held", false)
	var elapsed_ticks: int = current_tick - tick_of_accel_start
	jetpack_player.volume_db = lerp(
		MIN_JETPACK_DB,
		MAX_JETPACK_DB,
		min(1.0, float(elapsed_ticks) / MIN_ACCEL_TICKS),
	)
	if not boost_over:
		if not input_held and elapsed_ticks > MIN_ACCEL_TICKS:
			boost_over = true
		elif elapsed_ticks >= ACCEL_TICKS:
			boost_over = true
	if boost_over:
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
