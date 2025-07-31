extends AnimatedSprite2D

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	rotation = (mouse_pos - global_position).angle() + deg_to_rad(90)
