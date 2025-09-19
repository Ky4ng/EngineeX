# scriptor : Chua Yun Sheng
# studentID: 2202740
# function : controls the function of the danger floors
#			 allowing it to kill players on contact
#			 and change the sprite of the danger floor depending on the level
extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	var current_level = get_current_level()

	if current_level >= 4 and current_level <= 6:
		sprite.play("cave")
	elif current_level >= 7 and current_level <= 10:
		sprite.play("spaceship")


func get_current_level() -> int:
	var current_scene_path = get_tree().current_scene.scene_file_path
	var scene_name = current_scene_path.get_file().get_basename()

	var regex = RegEx.new()
	regex.compile("\\d+$")  # match digits at the end
	var result = regex.search(scene_name)

	if result:
		return int(result.get_string())
	else:
		return 0  # fallback if no number found
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.has_method("die"):
		body.die()
