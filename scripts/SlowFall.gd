# scriptor : Chua Kek Yang
# studentID: 2103936
# function : Slow-fall component. When the action is held in air, returns a lower
#            gravity to the player and (optionally) caps downward speed.

extends Node
class_name SlowFall

@export var action: StringName = "spacebar"   # input to hold for slow-fall
@export var enable_coyote_time: bool = false  # small grace after leaving ground
@export var coyote_time: float = 0.12         # seconds of coyote time
@export var glide_buffer_time: float = 0.0    # input buffer; 0 to disable
@export var use_fall_cap: bool = true         # cap extreme fall speeds
@export var max_fall_speed: float = 1400.0    # pixels/sec cap if enabled

var _coyote: float = 0.0
var _buffer: float = 0.0

func _physics_process(delta: float) -> void:
	# Keep timers updated from the parent (CharacterBody2D)
	var p := get_parent() as CharacterBody2D
	if p == null:
		return

	# Coyote time window after leaving ground (optional)
	if p.is_on_floor():
		_coyote = coyote_time
	elif enable_coyote_time:
		_coyote = max(_coyote - delta, 0.0)
	else:
		_coyote = 0.0

	# Simple input buffer (optional)
	if Input.is_action_just_pressed(action):
		_buffer = glide_buffer_time
	else:
		_buffer = max(_buffer - delta, 0.0)

func choose_gravity(normal_gravity: float, glide_gravity: float, player: CharacterBody2D) -> float:
	# Decide which gravity to apply this frame.
	if player.is_on_floor():
		return normal_gravity
	var pressed := Input.is_action_pressed(action) or (_buffer > 0.0)
	var coyote_ok := (not enable_coyote_time) or (_coyote <= 0.0)
	return glide_gravity if pressed and coyote_ok else normal_gravity

func clamp_fall_velocity(v: Vector2) -> Vector2:
	# Optional safety: cap maximum downward speed
	if use_fall_cap and v.y > max_fall_speed:
		v.y = max_fall_speed
	return v

func is_active(player: CharacterBody2D) -> bool:
	# True while slow-fall is currently engaged (for animations/FX)
	return (not player.is_on_floor()) and Input.is_action_pressed(action)
