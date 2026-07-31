extends Node

var gpu_pool: ObjectPool


func _ready() -> void:
	gpu_pool = ObjectPool.new()
	gpu_pool.init("ParticleManagerPool", _generate_gpu_particles)


func play_particle_frame_one_shot(frame: ParticleFrame) -> void:
	print(frame)


# 	var new_particles: GPUParticles2D = gpu_pool.request()
# 	use_frame(new_particles, frame)
# 	new_particles.finished.connect(
# 		release_gpu_particles.bind(new_particles),
# 		CONNECT_ONE_SHOT,
# 	)
# 	new_particles.play()
#
func release_gpu_particles(p: GPUParticles2D) -> void:
	p.get_parent().remove_child(p)
	gpu_pool.release(p)


func request_gpu_particles() -> GPUParticles2D:
	return gpu_pool.request()


func _generate_gpu_particles() -> GPUParticles2D:
	var new_particles = GPUParticles2D.new()
	add_child(new_particles)
	return new_particles
