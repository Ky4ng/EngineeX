extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings: Panel = $Settings



func _on_start_pressed():
	get_tree().change_scene_to_file("res://scene/sampleScene.tscn")
	print("Start pressed")

func _on_exit_pressed():
	get_tree().quit()



func _on_setting_pressed():
	print("Settings pressed")
	main_buttons.visible = false
	settings.visible = true

#Triggered when start the game
func _ready():
	main_buttons.visible = true
	settings.visible = false

func _on_back_pressed() -> void:
	_ready()
