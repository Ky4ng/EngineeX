extends CharacterBody2D

@export var speed = 200
@export var gravity = 1200
@export var launch_strength = 300

var in_launch = false

func apply_launch(force: Vector2) -> void:
	velocity = force
	in_launch = true

func _physics_process(delta) -> void:
	# Apply gravity when not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# Horizontal movement (disabled during launch)
	if not in_launch:
		var direction := 0.0
		if Input.is_action_pressed("a"):
			direction -= 1.0
		if Input.is_action_pressed("d"):
			direction += 1.0
		velocity.x = direction * speed

	# Launch velocity damping
	if in_launch:
		velocity = velocity.move_toward(Vector2.ZERO, launch_strength * delta)
		if is_on_floor() or velocity.length() < 10.0:
			in_launch = false

	# Move the character using built-in motion
	move_and_slide()
