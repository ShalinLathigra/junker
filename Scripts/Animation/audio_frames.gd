class_name AudioFrames
extends Resource

@export var samples: Dictionary[int, AudioFrame]


func invoke(frame: int) -> void:
	if not samples.has(frame):
		return

	AudioManager.play_audio_frame(samples[frame])
