@abstract class_name State
extends StateMachine


# Reference to the main state machine
# var state_machine: StateMachine
# Setup on state enter
func enter() -> void:
	# when I enter a state, immediately check transitions to see if a child
	# state needs to enter as well
	check_transitions()


# Teardown on state exit, cache details here
func exit() -> void:
	# immediately invoke child state's 'exit' clause if child exists
	if current_state:
		current_state.exit()
	current_state = null


# Check if ready to transition to this state or a child state
func is_ready() -> bool:
	for state in child_states:
		if state.is_ready():
			return true
	return false
