class_name StateMachine
extends RefCounted

# Future effort, convert nodes to refcounted!
@export var debug: bool

var id: String
var current_state: State
var child_states: Array[State]
var blackboard: Dictionary


func register_states(states: Array[State]) -> void:
	child_states.append_array(states)


func init() -> void:
	id = get_script().get_global_name()
	for child in child_states:
		child.init()


func inject(bb: Dictionary) -> void:
	blackboard = bb
	for child in child_states:
		(child as StateMachine).inject(bb)


func tick(delta: float):
	# check_transitions([])
	# Get the current state tree immediately, pass that in to check_transitions
	# Then, within check_transitions, we pass along the
	check_transitions(_get_state_line())
	# leaf states won't have children
	if current_state:
		current_state.tick(delta)


func physics_tick(delta: float):
	if current_state:
		current_state.physics_tick(delta)


func check_transitions(old_line: Array[State]) -> void:
	# check_transitions stays as a "
	# Pick out the next state we're moving to
	var next_state: State
	for state in child_states:
		if state.is_ready(old_line):
			next_state = state
			break
	if next_state == current_state or next_state == null:
		return
	if debug:
		# Print summary first
		var old_id: String = "null"
		var message: String = "%s Transition: %s -> %s (%d)" % [
			id,
			old_id,
			next_state.id,
			Time.get_ticks_msec(),
		]
		print(message)
		if current_state:
			old_id = current_state.id
		# Print the detailed tree next
		State.print_line(old_line)
	if current_state:
		current_state.exit()
	# maybe we also pass a reference to the previous state in to enter()
	# and exit() to allow a hook for specific transitions
	current_state = next_state
	current_state.enter(old_line)


func _get_state_line() -> Array[State]:
	var ret: Array[State] = []
	if current_state != null:
		ret.push_back(current_state)
		ret.append_array(current_state._get_state_line())
	return ret


func _init_states(state: Array[State]) -> void:
	child_states.push_back(state)
