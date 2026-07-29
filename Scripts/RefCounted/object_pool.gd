class_name ObjectPool
extends RefCounted

const _START_COUNT = 50
const _GENERATE_STEP = 5

var id: String
var _generator: Callable
#	Callable on_aquire
#	Callable on_return
var _available: Array[Variant] = []


# Not sure if I really need to be tracking this atm.
# var _in_use: Array
func init(id_in: String, generator: Callable) -> void:
	id = id_in
	_generator = generator
	_spawn_count(_START_COUNT)


func release(v: Variant) -> void:
	if _is_invalid(v):
		return
	_available.append(v)


func clear() -> void:
	# Free it
	for v in _available:
		if v is Node:
			v.queue_free()
		elif v is Object and v.has_method("free"):
			v.free()
	_available.clear()


func request() -> Variant:
	_spawn_if_needed()
	var next = _available.pop_back()
	assert(not _is_invalid(next), "%s Retrieved null or invalid entry")
	return _available.pop_back


func count_pool() -> int:
	return len(_available)


func _is_invalid(v: Variant) -> bool:
	return v == null or (v is Object and not is_instance_valid(v))


func _spawn_count(n: int) -> void:
	assert(_generator.is_valid(), "%s spawning with invalid generator" % id)
	for i in n:
		_available.append(_generator.call())


func _spawn_if_needed() -> void:
	if len(_available) <= 0:
		_spawn_count(_GENERATE_STEP)
		assert(len(_available) >= _GENERATE_STEP, "%s Failed to spawn nodes" % id)
