# scriptor : Liew Zhen Yang
# studentID : 2302645
#function : control the size of the window, if on will turn to windowed, then off turn to full screen

extends CheckButton


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
