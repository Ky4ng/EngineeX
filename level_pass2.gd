extends Area2D

@export var next_level_path: String = "res://test.tscn"  # Set your next scene path here

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name)
	if body.name == "Thelma":  # Must match the name in the scene tree exactly
		await get_tree().create_timer(0.01).timeout
		get_tree().change_scene_to_file(next_level_path)
