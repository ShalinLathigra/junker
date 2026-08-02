class_name PlayerGround
extends State

signal landed


func enter(old_line: Array[State] = []) -> void:
	if State.line_has_state(old_line, PlayerAir):
		landed.emit()


func tick(delta: float) -> void:
	blackboard.tick_of_last_ground = Time.get_ticks_msec()
	super.tick(delta)
