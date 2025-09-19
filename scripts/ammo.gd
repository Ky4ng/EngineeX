# scriptor : Liew Zhen Yang
# studentID : 2302645
# function : shows the amount of ammo left before the player needs to reload
extends CanvasLayer

@export var max_ammo_value: int = 3
@export var reload_speed: float = 0.3 # time between the ammo reloaded (sec)

var current_ammo_value: int = max_ammo_value
var is_reloading: bool = false
var blink_tween                               # store tween animation

@onready var current_ammo: Label = $HBoxContainer/AmmoContainer/CurrentAmmo
@onready var max_ammo: Label = $HBoxContainer/AmmoContainer/MaxAmmo
@onready var reload_label: Label = $ReloadLabel

func _ready() -> void:
	max_ammo.text = str(max_ammo_value)
	reload_label.visible = false
	update_ammo_display()

func shoot() -> void:
	if current_ammo_value > 0 and not is_reloading:
		current_ammo_value -= 1
		update_ammo_display()
		hide_reload_label() # hide when shoot
	if current_ammo_value == 0:
		print("Need Reloaded!")
		show_reload_label()

func reload() -> void:
	if is_reloading:
		return
	is_reloading = true
	start_reload()

func start_reload() -> void:
	hide_reload_label() # click R will hide
	while current_ammo_value < max_ammo_value:
		await get_tree().create_timer(reload_speed).timeout
		current_ammo_value += 1
		update_ammo_display()
	is_reloading = false # after reloaded

func update_ammo_display() -> void:
	current_ammo.text = str(current_ammo_value)

func show_reload_label() -> void:
	if get_tree().paused:
		return                       # do not show while game is paused
	reload_label.visible = true
	start_blinking()

func hide_reload_label() -> void:
	reload_label.visible = false
	if blink_tween:
		blink_tween.kill()           # stop animation
	reload_label.modulate.a = 1.0

# start blink
func start_blinking() -> void:
	if blink_tween:
		blink_tween.kill()
	blink_tween = create_tween()
	blink_tween.set_loops()
	blink_tween.tween_property(reload_label, "modulate:a", 0.0, 0.5)
	blink_tween.tween_property(reload_label, "modulate:a", 1.0, 0.5)
