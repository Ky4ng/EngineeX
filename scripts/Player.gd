# scriptor : Chua Yun Sheng
# studentID : 2202740
# function : controls the functions of the player,
#            like movement speed, glide/normal gravity, launch deceleration, and death/respawn effects
#
# scriptor : Chua Kek Yang
# studentID : 2103936
# function : controls gravity (slow falling - while glide [press space]),
#            set Invulnerability state after respawned, and adds dash & land on W.

extends CharacterBody2D

@export var speed: float = 600
@export var normal_gravity: float = 900
@export var glide_gravity: float = 400
@export var launch_strength: float = 300
@export var stop_threshold: float = 10.0
@export var deceleration: float = 0.985

# --- spawn effects & invulnerability ---
@export var respawn_invuln_seconds: float = 2.0
@export var blink_min_alpha: float = 0.35     # 0..1 (how transparent during blink)
@export var blink_step: float = 0.1           # seconds per blink half-cycle
@export var spawn_shake_amp: float = 6.0
@export var spawn_shake_dur: float = 0.35

# --- DASH (press W) ---
@export var dash_speed: float = 400.0        # strength of the dash n land
@export var dash_cooldown: float = 0.35       # seconds before next dash
@export var dash_air_ok: bool = true          # allow in air
@export var dash_vertical: bool = false       # set true to dash UP with W instead of forward

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slowfall: SlowFall = get_node_or_null("SlowFall")

var in_launch: bool = false
var is_dead: bool = false
var drop_timer: float = 0.0

# invulnerability state
var invulnerable: bool = false
var _blink_tween: Tween

# dash state
var _dash_cd := 0.0
var _last_dir := 1.0

func _ready() -> void:
	# Ensure 'dash' action exists and is bound to W
	if not InputMap.has_action("dash"):
		InputMap.add_action("dash")
		var ev := InputEventKey.new()
		ev.physical_keycode = KEY_W
		InputMap.action_add_event("dash", ev)
		print("[Player] Created 'dash' action bound to W")

	# Spawn effects
	_camera_shake_on_spawn()
	_start_invulnerability(respawn_invuln_seconds)

func apply_launch(force: Vector2) -> void:
	velocity = force
	in_launch = true

func _physics_process(delta: float) -> void:
	var direction: float = 0.0
	if Input.is_action_pressed("a"): direction -= 1.0
	if Input.is_action_pressed("d"): direction += 1.0
	if Input.is_action_pressed("restart"):
		call_deferred("die")

	# Track last facing for forward dash
	var face_dir := direction
	if face_dir == 0.0 and is_instance_valid(sprite):
		face_dir = -1.0 if sprite.flip_h else 1.0
	_last_dir = face_dir if face_dir != 0.0 else _last_dir

	# --- DASH: trigger on W (action "dash") ---
	_dash_cd = max(_dash_cd - delta, 0.0)
	if Input.is_action_just_pressed("dash") and _dash_cd == 0.0 and (is_on_floor() or dash_air_ok):
		var launch_vec := Vector2(_last_dir * dash_speed, 0.0)
		if dash_vertical:
			launch_vec = Vector2(0.0, -dash_speed)
		apply_launch(launch_vec)
		_dash_cd = dash_cooldown
		var cam := get_viewport().get_camera_2d()
		if cam and cam.has_method("shake"):
			cam.call("shake", 5.0, 0.2)
		# print("[Player] Dash fired: ", launch_vec)  # uncomment to debug

	# --- Animation state ---
	if slowfall and slowfall.is_active(self):
		if not is_on_floor():
			sprite.play("glide")
		else:
			sprite.play("idle")
	else:
		if direction != 0:
			sprite.play("walk")
			sprite.flip_h = direction < 0
		else:
			sprite.play("idle")

	# --- Gravity selection (delegated to SlowFall if present) ---
	var current_gravity := normal_gravity
	if slowfall:
		current_gravity = slowfall.choose_gravity(normal_gravity, glide_gravity, self)
	else:
		if Input.is_action_pressed("spacebar") and not is_on_floor():
			current_gravity = glide_gravity

	# Apply gravity when airborne
	if not is_on_floor():
		velocity.y += current_gravity * delta

	if in_launch:
		var input_force: float = direction * 400 * delta
		velocity.x += input_force
		velocity = velocity.move_toward(Vector2(velocity.x, 0), launch_strength * delta)

		if is_on_floor() and velocity.length() <= stop_threshold:
			velocity = Vector2.ZERO

		if is_on_floor() and velocity.length() < 10000.0:
			velocity = velocity * deceleration

		if is_on_floor() and velocity.length() <= 0.0:
			in_launch = false
	else:
		velocity.x = direction * speed

	# Optional: cap extreme downward speed via SlowFall
	if slowfall:
		velocity = slowfall.clamp_fall_velocity(velocity)

	move_and_slide()

func die():
	# Ignore death while invulnerable or if already dying
	if is_dead or invulnerable:
		return
	is_dead = true

	print("Player died! Respawning...")
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)

	call_deferred("_reload_scene")

func _reload_scene():
	get_tree().reload_current_scene()

# =========================
# Invulnerability + Blink
# =========================
func _start_invulnerability(duration: float) -> void:
	if duration <= 0.0:
		return
	invulnerable = true
	_start_blink()
	await get_tree().create_timer(duration).timeout
	_end_invulnerability()

func _end_invulnerability() -> void:
	invulnerable = false
	_stop_blink()

func _start_blink() -> void:
	if _blink_tween:
		_blink_tween.kill()
	_blink_tween = create_tween()
	_blink_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_blink_tween.set_loops()
	_blink_tween.tween_property(sprite, "modulate:a", blink_min_alpha, blink_step)
	_blink_tween.tween_property(sprite, "modulate:a", 1.0, blink_step)

func _stop_blink() -> void:
	if _blink_tween:
		_blink_tween.kill()
	sprite.modulate = Color(1, 1, 1, 1)

# =========================
# Camera shake on spawn
# =========================
func _camera_shake_on_spawn() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("shake"):
		cam.call("shake", spawn_shake_amp, spawn_shake_dur)
