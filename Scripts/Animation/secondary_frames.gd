class_name SecondaryAnimator
extends Node

# This is a companion node that hooks in to a sprite animator
# listens for frame changes, animation changes, etc. and 
# triggers secondary effects, i.e. audio playback, when the attached
# dictionary frames say it should
@export var target: SpriteAnimator
@export var secondary_frames: Dictionary[StringName, SecondaryFrames]


func _ready() -> void:
	assert(target != null, "Cannot run without a target")
	target.frame_changed.connect(_on_frame_changed)
	target.animation_changed.connect(_on_frame_changed)


func _on_frame_changed() -> void:
	if not secondary_frames.has(target.animation):
		return
	secondary_frames[target.animation].invoke(target.frame)
