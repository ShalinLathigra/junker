@abstract class_name State
extends StateMachine


func enter(old_line: Array[State] = []) -> void:
	# when I enter a state, immediately check transitions to see if a child
	# state needs to enter as well
	check_transitions(old_line)
	# if check_transitions, pass the old tree directly in to the next
	# state

	# i.e. player will go straight in to idle probably, unless movement input
	# is provided.
	# Maybe we want a hook for special state behaviours here?


# Teardown on state exit, cache details here
func exit() -> void:
	# immediately invoke child state's 'exit' clause if child exists
	if current_state:
		current_state.exit()
	current_state = null


# Check if ready to transition to this state or a child state
func is_ready(_old_line: Array[State]) -> bool:
	for state in child_states:
		if state.is_ready(_old_line):
			return true
	return false
