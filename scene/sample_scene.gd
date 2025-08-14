extends Control

@onready var button: Button = $SampleScene/Button
@onready var pause_menu: VBoxContainer = $Panel2/PauseMenu
@onready var panel_2: Panel = $Panel2



func _on_pause_pressed():
	print("Pause pressed")
	panel_2.visible = true
	pause_menu.visible = true

func _ready():
	panel_2.visible = false
	pause_menu.visible = false


func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://maiin_ menu.tscn")
	print("Back To Menu Pressed")


func _on_resume_pressed():
	print("Resume pressed")
	panel_2.visible = false


func _on_restart_pressed():
	pass # Replace with function body.
