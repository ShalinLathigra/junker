class_name SecondaryFrames
extends Resource

@export var frames: Dictionary[int, SecondaryFrame]


func invoke(frame: int) -> void:
	if not frames.has(frame):
		return
	frames[frame].invoke()
