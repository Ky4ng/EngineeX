extends CharacterBody2D

@export var speed: float = 600
@export var gravity: float = 1200
@export var launch_strength: float = 300
@export var stop_threshold: float = 10.0
@export var deceleration: float = 0.985

var in_launch: bool = false

func apply_launch(force: Vector2) -> void:
	velocity = force
	in_launch = true

func _physics_process(delta: float) -> void:
	var direction: float = 0.0

	if Input.is_action_pressed("a"):
		direction -= 1.0
	if Input.is_action_pressed("d"):
		direction += 1.0

	# Apply gravity when not grounded
	if not is_on_floor():
		velocity.y += gravity * delta

	if in_launch:
		# Add control influence on top of launch movement
		var input_force: float = direction * 400 * delta
		velocity.x += input_force
	   
		# Apply launch damping toward stopping
		velocity = velocity.move_toward(Vector2(velocity.x, 0), launch_strength * delta)

		# Dampen all movement when grounded


		# Stop launch if mostly still and grounded
		if is_on_floor() and velocity.length() <= stop_threshold:
			velocity = Vector2.ZERO
		if is_on_floor() && velocity.length() < 10000.0:
			velocity = velocity * 0.985 
		if is_on_floor() && velocity.length() <= 00.0:
			in_launch = false
		
	else:
		# Normal grounded movement
		velocity.x = direction * speed

	move_and_slide()

func die():
	print("Player died! Respawning...")
	await get_tree().create_timer(0.01).timeout
	get_tree().reload_current_scene()
