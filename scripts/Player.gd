extends CharacterBody2D

@export var speed: float = 600
@export var normal_gravity: float = 900
@export var glide_gravity: float = 400  # Lower gravity for gliding
@export var launch_strength: float = 300
@export var stop_threshold: float = 10.0
@export var deceleration: float = 0.985

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var in_launch: bool = false
var is_dead: bool = false  # Prevent multiple die() calls
var drop_timer: float = 0.0

func apply_launch(force: Vector2) -> void:
	velocity = force
	in_launch = true

func _physics_process(delta: float) -> void:
	var direction: float = 0.0

	if Input.is_action_pressed("a"):
		direction -= 1.0
	if Input.is_action_pressed("d"):
		direction += 1.0
	if Input.is_action_pressed("restart"):
		call_deferred("die") 

	# Animation state
	if direction != 0:
		sprite.play("walk")
		sprite.flip_h = direction < 0
	else:
		sprite.play("idle")

	# Choose gravity based on spacebar press in air
	var current_gravity = normal_gravity
	if Input.is_action_pressed("spacebar") and not is_on_floor():
		current_gravity = glide_gravity 

	# Apply gravity when not grounded
	if not is_on_floor():
		velocity.y += current_gravity * delta

	if in_launch:
		# Add control influence on top of launch movement
		var input_force: float = direction * 400 * delta
		velocity.x += input_force

		# Apply launch damping toward stopping
		velocity = velocity.move_toward(Vector2(velocity.x, 0), launch_strength * delta)

		# Stop launch if mostly still and grounded
		if is_on_floor() and velocity.length() <= stop_threshold:
			velocity = Vector2.ZERO

		if is_on_floor() and velocity.length() < 10000.0:
			velocity = velocity * deceleration

		if is_on_floor() and velocity.length() <= 0.0:
			in_launch = false
	else:
		# Normal grounded movement
		velocity.x = direction * speed

	move_and_slide()

func die():
	if is_dead:
		return  # Already dead, ignore extra calls
	is_dead = true

	print("Player died! Respawning...")
	sprite.modulate = Color(1, 0, 0)  # Flash red

	await get_tree().create_timer(0.1).timeout  # Short flash
	sprite.modulate = Color(1, 1, 1)  # Reset color

	call_deferred("_reload_scene")  # Safer than direct reload in physics step

func _reload_scene():
	get_tree().reload_current_scene()
