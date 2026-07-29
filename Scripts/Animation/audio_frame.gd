class_name AudioFrame
extends Resource

@export var stream: AudioStream
@export_range(-80.0, 24.0, 0.1) var volume_db: float = 0.0
@export_range(0.0, 16.0, 0.1) var pitch_scale: float = 1.0
