class_name SpriteAnimator
extends AnimatedSprite2D

const DEBUG_MODE: bool = true

# Same as AnimatedSprite2D, but it comes with a queue 
var animation_queue: Array[String]
var callback: Callable
var default_anchor: Vector2


func _ready() -> void:
	# animation_looped is the other signal
	animation_finished.connect(on_animation_finished)
	default_anchor = offset


func safe_play(anim: String) -> void:
	if DEBUG_MODE:
		if not sprite_frames.has_animation(anim):
			push_warning(
				"Trying to play a null animation: ",
				anim,
				" on node: ",
				get_parent(),
			)
			return
	else:
		assert(
			sprite_frames.has_animation(anim),
			"Attempting to play empty animation",
		)
	play(anim)


func enqueue(anim: String, cb: Callable = Callable()) -> void:
	var pair = _new_ac_pair(anim, cb)
	animation_queue.push_back(pair)


# Trashes queue, plays target animation immediately
func play_immediate(anim: String, cb: Callable = Callable()) -> void:
	animation_queue = []
	callback = cb
	safe_play(anim)


func play_queued() -> void:
	play_next()


func on_animation_finished() -> void:
	if callback:
		callback.call()
	play_next()


func play_next() -> void:
	if animation_queue.size() <= 0:
		return
	var to_play: AnimationCallbackPair = animation_queue.pop_front()
	callback = to_play.callback
	safe_play(to_play.anim)


# want_rigth means that the sprite SHOULD be pointing towards the right
# is_right_facing means that a sprite by default faces right
func point_towards(want_right: bool, is_right_facing: bool) -> void:
	if want_right and is_right_facing:
		flip_h = false
		offset = default_anchor
	else:
		flip_h = true
		offset = Vector2(-default_anchor.x, default_anchor.y)


func _new_ac_pair(anim, cb) -> AnimationCallbackPair:
	var ac = AnimationCallbackPair.new()
	ac.anim = anim
	ac.callback = cb
	return ac


class AnimationCallbackPair:
	var anim: String
	var callback: Callable
