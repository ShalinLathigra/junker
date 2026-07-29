extends Node

# AudioManager.gd
# High level thoughts
# Used to create and manage playing of one-off audio clips
# Will use grab bags of 2D and 1D audio
# Tracks looping background tracks as well as instantaneous audio
# Listens to "play_audio" and "play_audio_2d" signal or something like that to handle
# 	dealing with directional audio vs non-directional audio
# Doe this need to go through a signal bus? Maybe not actually. This just exposes the options, other
# things will listen to signals and actually trigger the behaviour
var audio_pool: ObjectPool


func _ready() -> void:
	audio_pool = ObjectPool.new()
	audio_pool.init("AudioManagerPool", _generate_audio_player)


func _generate_audio_player() -> AudioStreamPlayer:
	return AudioStreamPlayer.new()
