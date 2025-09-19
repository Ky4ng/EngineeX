# scriptor : Chua Yun Sheng
# studentID : 2202740
# function : controls the functions of the player,
#            like movement speed, glide/normal gravity, launch deceleration, and death/respawn effects

# scriptor : Chua Kek Yang
# studentID : 2103936
# function : controls gravity (slow falling - while glide [press space],
#            set Invulnerability state after respawned.

extends CharacterBody2D

@export var speed: float = 600
@export var normal_gravity: float = 900
@export var glide_gravity: float = 400
@export var launch_strength: float = 300
@export var stop_threshold: float = 10.0
@export var deceleration: float = 0.985

# --- NEW: spawn effects & invulnerability ---
@export var respawn_invuln_seconds: float = 2.0
@export var blink_min_alpha: float = 0.35     # 0..1 (how transparent during blink)
@export var blink_step: float = 0.1           # seconds per blink half-cycle
@export var spawn_shake_amp: float = 6.0
@export var spawn_shake_dur: float = 0.35

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slowfall: SlowFall = get_node_or_null("SlowFall")

var in_launch: bool = false
var is_dead: bool = false
var drop_timer: float = 0.0

# --- NEW: invulnerability state ---
var invulnerable: bool = false
var _blink_tween: Tween

func _ready() -> void:
	# Camera shake + temporary invulnerability on (re)spawn
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
	_blink_tween.set_loops()  # keep blinking until we end invuln
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
