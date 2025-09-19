# scriptor : Liew Zhen Yang
# studentID : 2302645
# function : allows the player to pause in a level,
#			 the player can resume, restart the level or exit to the main menu
extends Control
signal paused_changed(paused: bool)

@export var pause_action: String = "Pause"
@export var panel_path: NodePath = ^"Panel2"
@export var reload_label_path: NodePath

@onready var panel_2: CanvasItem = get_node_or_null(panel_path)
var reload_label: CanvasItem = null
var is_open := false
var _reload_was_visible := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resolve_reload_label()
	_close_menu()

func _resolve_reload_label() -> void:
	# 1) Prefer used the path assigned in the Inspector
	if reload_label == null and reload_label_path != NodePath(""):
		reload_label = get_node_or_null(reload_label_path) as CanvasItem

	 # 2) Fallback: search by name across the tree (change "ReloadLabel" if your node has another name)
	if reload_label == null:
		reload_label = get_tree().get_root().find_child("ReloadLabel", true, false) as CanvasItem

	 # 3) Fallback: search by group (add your label to group "ReloadUI")
	if reload_label == null:
		var n := get_tree().get_first_node_in_group("ReloadUI")
		reload_label = n as CanvasItem

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(pause_action):
		_toggle_pause()

func _toggle_pause() -> void:
	is_open = !is_open
	if is_open:
		_open_menu()
	else:
		_close_menu()


func _open_menu() -> void:
	get_tree().paused = true
	if panel_2: panel_2.visible = true
	visible = true

	if reload_label == null:
		_resolve_reload_label()  # try it again 

	if reload_label:
		_reload_was_visible = reload_label.visible
		reload_label.visible = false
		reload_label.process_mode = Node.PROCESS_MODE_DISABLED

	emit_signal("paused_changed", true)

func _close_menu() -> void:
	get_tree().paused = false
	if panel_2: panel_2.visible = false
	visible = false

	if reload_label:
		reload_label.process_mode = Node.PROCESS_MODE_INHERIT
		reload_label.visible = _reload_was_visible

	emit_signal("paused_changed", false)

func _on_resume_pressed() -> void:
	_close_menu()

func _on_restart_pressed() -> void:
	var path := get_tree().current_scene.scene_file_path
	_close_menu()
	get_tree().change_scene_to_file(path)

func _on_back_to_menu_pressed() -> void:
	_close_menu()
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
