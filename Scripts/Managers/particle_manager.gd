extends Node

var gpu_pool: ObjectPool


func _ready() -> void:
	gpu_pool = ObjectPool.new()
	gpu_pool.init("ParticleManagerPool", _generate_gpu_particles)


func play_particle_frame_one_shot(frame: ParticleFrame, target_position: Vector2) -> void:
	prints(frame, "at", target_position)
	var new_particle: GPUParticles2D = request_gpu_particles()
	new_particle.finished.connect(
		release_gpu_particles.bind(new_particle),
		CONNECT_ONE_SHOT,
	)
	use_frame(new_particle, frame, target_position)
	new_particle.restart(true)


func use_frame(
		part: GPUParticles2D,
		frame: ParticleFrame,
		target_position: Vector2,
) -> void:
	part.material = frame.material
	part.texture = frame.texture
	part.amount = frame.amount
	part.explosiveness = frame.explosiveness
	part.lifetime = frame.lifetime
	part.global_position = target_position + frame.offset


func release_gpu_particles(p: GPUParticles2D) -> void:
	if p.get_parent() != self:
		p.reparent(self)
	gpu_pool.release(p)


func request_gpu_particles() -> GPUParticles2D:
	return gpu_pool.request()


func _generate_gpu_particles() -> GPUParticles2D:
	var new_particles = GPUParticles2D.new()
	add_child(new_particles)
	return new_particles
