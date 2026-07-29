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


func play_audio_frame(frame: AudioFrame) -> void:
	var new_player: AudioStreamPlayer = audio_pool.request()
	new_player.stream = frame.stream
	new_player.volume_db = frame.volume_db
	new_player.pitch_scale = frame.pitch_scale
	new_player.finished.connect(
		release_audio_player.bind(new_player),
		CONNECT_ONE_SHOT,
	)
	new_player.play()


func release_audio_player(p: AudioStreamPlayer) -> void:
	p.stop()
	audio_pool.release(p)


func request_audio_player() -> AudioStreamPlayer:
	return audio_pool.request()


func _generate_audio_player() -> AudioStreamPlayer:
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	return new_player
