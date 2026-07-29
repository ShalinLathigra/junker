extends Label

@export var target_node: Node

var state_machine: StateMachine


func _process(_delta: float) -> void:
	if state_machine == null:
		state_machine = target_node.get("state_machine")
		assert(state_machine != null, "Failed to lazy fetch state_machine")
	var message: String = ""
	var current_state = state_machine.current_state
	while current_state != null:
		message = "%s\n%s" % [current_state.id, message]
		current_state = current_state.get("current_state")
	text = message
