# scriptor : Chua Yun Sheng
# studentID : 2202740
# function : controls the function of the jetpack, 
#			 allowing hold to slowly glide
extends Node2D

@onready var jetpack_sound: AudioStreamPlayer2D = $JetPackSound
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta):
	if Input.is_action_pressed("spacebar"):
		sprite.play("glide")
		
		if jetpack_sound and not jetpack_sound.playing:
			jetpack_sound.play()
	else:
		sprite.play("default")  # or another animation
		
		if jetpack_sound and jetpack_sound.playing:
			jetpack_sound.stop()
