
# scriptor : Liew Zhen Yang
# studentID : 2302645
#function : control the start button at main menu
#           control the exit button at main menu
#           control the settings button at main menu, will be visible when click the button but will hide when start game

#scriptor : Liew Zhen Yang 
#function : control the start button at main menu
#           control the exit button at main menu
#           control the settings button at main menu


extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings: Panel = $Settings



func _on_start_pressed():
	get_tree().change_scene_to_file("res://levelSelect/level_select.tscn")
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
