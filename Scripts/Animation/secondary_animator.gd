@tool
class_name SecondaryAnimator
extends Node

# This is a companion node that hooks in to a sprite animator
# listens for frame changes, animation changes, etc. and 
# triggers secondary effects, i.e. audio playback, when the attached
# dictionary frames say it should
@export var target: SpriteAnimator
@export var audio_frames: Dictionary[StringName, AudioFrames]


# @export_tool_button(
# 	"Init From Target",
# 	"Callable",
# )
# var init_action = _init_from_target
func _ready() -> void:
	assert(target != null, "Cannot run without a target")
	target.frame_changed.connect(_on_frame_changed)
	target.animation_changed.connect(_on_frame_changed)


func _on_frame_changed() -> void:
	if not audio_frames.has(target.animation):
		return
	audio_frames[target.animation].invoke(target.frame)
	# target.animation_changed.connect(_on_animation_changed)
	# func _on_animation_changed() -> void:
	# 	prints("Changed animation to", target.animation)
# func _init_from_target() -> void:
# 	assert(
# 		Engine.is_editor_hint(),
# 		"Initializing secondary animator outside of engine! Stop that!",
# 	)
# 	if not target:
# 		push_error("SecondaryAnimator: _init_from_target: No target provided!")
# 		return
#
# 	var match_frames: SpriteFrames = target.sprite_frames
# 	if not match_frames:
# 		push_error(
# 			"SecondaryAnimator: _init_from_target: No SpriteFrames found on target %s!" % target.name,
# 		)
# 		return
# 	for anim in match_frames.get_animation_names():
# 		var length: int = match_frames.get_frame_count(anim)
# 		prints("processing", target.name, "animation:", anim, "with len:", length)
#
# 		if not audio_frames.has(anim):
# 			audio_frames[anim] = AudioFrames.new()
