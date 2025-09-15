extends Control 

@onready var pause_menu: VBoxContainer = $Panel2/PauseMenu 
@onready var panel_2: Panel = $Panel2 

func _physics_process(_delta: float) -> void: 
	if Input.is_action_just_pressed("Pause"): 
		print("Pause pressed") 
		panel_2.visible = true 
		pause_menu.visible = true 
		
func _ready(): 
	panel_2.visible = false 
	pause_menu.visible = false 
	
func _on_back_to_menu_pressed(): 
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn") 
	print("Back To Menu Pressed") 
	
func _on_resume_pressed(): 
	print("Resume pressed") 
	panel_2.visible = false 

func _on_restart_pressed(): 
	get_tree().reload_current_scene()
