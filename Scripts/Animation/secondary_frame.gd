class_name SecondaryFrame
extends Resource

@export var particles: Array[ParticleFrame]
@export var samples: Array[AudioFrame]


func invoke() -> void:
	for sample in samples:
		AudioManager.play_audio_frame_one_shot(sample)
	for part in particles:
		ParticleManager.play_particle_frame_one_shot(part)
