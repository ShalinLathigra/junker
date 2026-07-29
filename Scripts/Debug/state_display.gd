extends Label

@export var target_node: Node


func _process(_delta: float) -> void:
	var message: String = ""
	var current_state = target_node.get("current_state")
	while current_state != null:
		message = "%s\n%s" % [current_state.name, message]
		current_state = current_state.get("current_state")
	text = message
