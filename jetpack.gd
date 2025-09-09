extends Node2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta):
	if Input.is_action_pressed("spacebar"):
		sprite.play("glide")
	else:
		sprite.play("default")  # or another animation
