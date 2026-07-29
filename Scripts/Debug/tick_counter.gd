extends Label


func _process(_delta: float) -> void:
	text = "%d" % Time.get_ticks_msec()
