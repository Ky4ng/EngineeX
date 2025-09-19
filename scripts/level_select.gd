extends Button


func _on_level_select():
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
	print("Back pressed")


func _on_level_1_pressed():
	get_tree().change_scene_to_file("res://Level/Level_1.tscn")
	print("Level 1 pressed")


func _on_level_2_pressed():
	get_tree().change_scene_to_file("res://Level/Level_2.tscn")
	print("Level 2 pressed")


func _on_level_3_pressed():
	get_tree().change_scene_to_file("res://Level/Level_3.tscn")
	print("Level 3 pressed")


func _on_level_4_pressed():
	get_tree().change_scene_to_file("res://Level/Level_4.tscn")
	print("Level 4 pressed")


func _on_level_5_pressed():
	get_tree().change_scene_to_file("res://Level/Level_5.tscn")
	print("Level 5 pressed")
	

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Level/Level_11.tscn")
	print("Level 11 pressed")


func _on_level_6_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/Level_6.tscn")
	print("Level 6 pressed")
	
func _on_level_7_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/Level_7.tscn")
	print("Level 7 pressed")

func _on_level_8_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/Level_8.tscn")
	print("Level 8 pressed")

func _on_level_9_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/Level_9.tscn")
	print("Level 9 pressed")


func _on_level_10_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/Level_10.tscn")
	print("Level 10 pressed")
