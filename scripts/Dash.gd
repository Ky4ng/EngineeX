# scriptor : Chua Kek Yang
# studentID : 2103936
# Press W (action "dash") to burst forward and land. Works on ground & in air.

extends Node
class_name Dash

@export var action: StringName = "dash"   # W should be bound to this
@export var dash_speed: float = 300.0
@export var dash_time: float = 0.18
@export var cooldown: float = 0.35
@export var air_ok: bool = true
@export var dash_vertical: bool = false   # set true to dash UP with W

var _cd := 0.0
var _active := 0.0
var _last_dir := 1.0

func _ready() -> void:
	# Safety: auto-create the action & bind W if it's missing
	if not InputMap.has_action(action):
		InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = KEY_W
		InputMap.action_add_event(action, ev)
		print("[Dash] Created action '%s' and bound W" % action)
	else:
		print("[Dash] Action '%s' exists" % action)

func _physics_process(delta: float) -> void:
	var p := get_parent() as CharacterBody2D
	if p == null:
		return

	# Track last facing/move direction
	var dir := 0.0
	if Input.is_action_pressed("a"): dir -= 1.0
	if Input.is_action_pressed("d"): dir += 1.0
	if dir == 0.0 and p.has_node("AnimatedSprite2D"):
		var spr := p.get_node("AnimatedSprite2D") as AnimatedSprite2D
		dir = -1.0 if spr.flip_h else 1.0
	_last_dir = dir if dir != 0.0 else _last_dir

	# Timers
	_cd = max(_cd - delta, 0.0)
	_active = max(_active - delta, 0.0)

	# Trigger on W (action "dash")
	if Input.is_action_just_pressed(action):
		print("[Dash] '%s' pressed" % action)
	if Input.is_action_just_pressed(action) and _cd == 0.0 and (p.is_on_floor() or air_ok):
		if dash_vertical:
			p.apply_launch(Vector2(0, -dash_speed))
			print("[Dash] UP dash fired")
		else:
			p.apply_launch(Vector2(_last_dir * dash_speed, 0.0))
			print("[Dash] FORWARD dash fired dir=", _last_dir)
		_active = dash_time
		_cd = cooldown

		# Optional camera shake
		var cam := p.get_viewport().get_camera_2d()
		if cam and cam.has_method("shake"):
			cam.call("shake", 5.0, 0.2)

func is_dashing() -> bool:
	return _active > 0.0
