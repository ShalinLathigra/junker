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


func check_transitions() -> void:
	# check_transitions stays as a "
	# Pick out the next state we're moving to
	var next_state: State
	for state in child_states:
		if state.is_ready():
			next_state = state
			break
	if next_state == current_state or next_state == null:
		return
	if debug:
		var old_id: String = "null"
		if current_state:
			old_id = current_state.id
		var message: String = "%s Transition: %s -> %s (%d)" % [
			id,
			old_id,
			next_state.id,
			Time.get_ticks_msec(),
		]
		print(message)
	if current_state:
		current_state.exit()
	current_state = next_state
	current_state.enter()


func tick(delta: float):
	check_transitions()
	# leaf states won't have children
	if current_state:
		current_state.tick(delta)


func physics_tick(delta: float):
	if current_state:
		current_state.physics_tick(delta)


func _init_states(state: Array[State]) -> void:
	child_states.push_back(state)
"""
Pending idea, go from "current state decides behaviour", with behaviour
	transitions happening top down

	to "State A is true, update the rest to match", where I can say "I am in
	state Jump, make the rest follow"


	First approach has the benefit that behaviour is really well broken down
		and allows non-explicit transitions to happen because all state is
		driven by what is read from the blackboards at the top level state
			machine
		Unfortunately, this means that it's a bit awkward to design higher
			order behaviours. Information must be stored or piped in via the
			blackboard, which is available, just gets messy and I need to be
			paying attention to variable ids, etc.
				Possibly avoidable by using node ids, etc. and a more
					sophisticated dict wrapper
	
	Second approach means I can hardcode transitions more easily
		i.e. if I am running and want to jump I can say that, but if I want to
			enter a special other state, I can explicitly assign that to the
			state machine
		- Same idea with things like going up a ladder or interacting with
			special one-off things, it'd be nice if hitting a ladder forced you
				into the 'ladder state', but you couldn't enter it any other
				way.
			That would probably lead to a bunch of other one-off bugs though
		- I think for now I'll proceed with this "top down" version, then I'll
			set up a second test area with the other version after this is
			somewhere interesting

move this "exit + enter" logic to a "change states" method
When you enter or exit, we need to:
1. Find the Whole line of transitions that need to happen
Start with the current state being asserted
add current state to position 0 of an array
while processing_state.get_parent != null and is a state machine
	machine_chain.append(processing_state.get_parent)
  processing = state
i.e. if I set ground control's state to "idle"
	idle state is null
	ground_control state is idle
	main state machine state is ground_control

"""
