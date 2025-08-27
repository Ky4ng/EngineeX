extends Area2D

var max_level: int = 10

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):  # Optional: only trigger for player
		var current_scene_path = get_tree().current_scene.scene_file_path
		var scene_name = current_scene_path.get_file().get_basename()  # e.g. "test3"

		# Extract number at the end of scene name using regex
		var regex = RegEx.new()
		regex.compile("\\d+$")  # match digits at the end
		var result = regex.search(scene_name)

		if result:
			var current_level = int(result.get_string())
			if current_level < max_level:
				var next_level_path = "res://Level/Level_%d.tscn" % (current_level + 1)
				call_deferred("_change_level", next_level_path)
			else:
				print("You are at the final level!")
				get_tree().change_scene_to_file("res://Menu/maiin_menu.tscn")
		else:
			print("No number found in scene name — cannot determine next level.")

func _change_level(path: String) -> void:
	get_tree().change_scene_to_file(path)
