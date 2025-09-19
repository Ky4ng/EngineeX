#Name: Dilan Rhaj
#StudentID: 2300088

extends Node2D

@export var fall_speed: float = 200.0
@export var destroy_y: float = 115.0  # adjust for your level
@export var spike_pieces_scene: PackedScene  # Make sure to set this in the inspector!
@export var pieces_spawn_delay: float = 0.1  # Delay before spawning pieces after hitting ground

var is_falling: bool = false
var has_left_initial_position: bool = false
var has_spawned_pieces: bool = false
var min_fall_distance: float = 20.0  # Minimum distance to fall before detecting ground
var hit_position: Vector2  # Store the position where the spike hit the ground

@onready var hitbox: Area2D = $Area2D
@onready var player_detect: Area2D = $PlayerDetect
@onready var floor_detect: Area2D = $FloorDetect

func _ready() -> void:
	print("=== SPIKE INITIALIZED ===")
	print("Initial position: ", position)
	
	# Check if spike pieces scene is assigned
	if spike_pieces_scene:
		print("Spike pieces scene is assigned: ", spike_pieces_scene.resource_path)
	else:
		print("WARNING: Spike pieces scene not assigned!")
	
	# Connect signals
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	if player_detect:
		player_detect.body_entered.connect(_on_player_detect_body_entered)
	
	if floor_detect:
		floor_detect.body_entered.connect(_on_floor_detect_body_entered)
		floor_detect.monitoring = false

func _process(delta: float) -> void:
	if is_falling and not has_spawned_pieces:  # Only move if we haven't spawned pieces yet
		position.y += fall_speed * delta
		print("Falling - Current Y: ", position.y, " | Distance fallen: ", position.y - 8.0)
		
		# Check if we've moved away from the initial position
		if not has_left_initial_position and (position.y - 8.0) > min_fall_distance:
			has_left_initial_position = true
			print("Spike has left initial position")
		
		# Remove if it falls below destroy_y
		if position.y > destroy_y and not has_spawned_pieces:
			print("Spike fell below destroy_y, spawning pieces before removing")
			has_spawned_pieces = true
			hit_position = global_position  # Store the current position
			spawn_spike_pieces()
			queue_free()

func _on_player_detect_body_entered(body: Node) -> void:
	print("PlayerDetect triggered by: ", body.name)
	if body.is_in_group("Player"):
		print("Player detected, starting to fall")
		start_falling()

func _on_hitbox_body_entered(body: Node) -> void:
	print("Hitbox triggered by: ", body.name)
	if is_falling and body.is_in_group("Player"):
		print("Spike hit player, removing")
		if body.has_method("die"):
			body.die()
		queue_free()

func _on_floor_detect_body_entered(body: Node) -> void:
	print("FloorDetect triggered by: ", body.name)
	print("Body is in Ground group: ", body.is_in_group("Ground"))
	
	# Only remove if we've left the initial position and hit ground
	if is_falling and body.is_in_group("Ground") and has_left_initial_position and not has_spawned_pieces:
		print("Spike hit ground after leaving initial position, spawning pieces and removing")
		has_spawned_pieces = true
		hit_position = global_position  # Store the current position
		
		# Stop the falling movement
		is_falling = false
		
		# Add a small delay before spawning pieces
		await get_tree().create_timer(pieces_spawn_delay).timeout
		
		spawn_spike_pieces()
		queue_free()
	elif is_falling and body.is_in_group("Ground"):
		print("Spike hit ground but condition not met, ignoring")
		
func start_falling() -> void:
	if not is_falling:
		print("Starting to fall")
		is_falling = true
		
		# Add a small delay before enabling floor detection
		await get_tree().create_timer(0.1).timeout
		
		# Enable floor detection
		if floor_detect:
			floor_detect.monitoring = true
			print("Floor detection enabled")

#func spawn_spike_pieces():
	#var all_pieces = get_tree().get_nodes_in_group("SpikePieces")
	#if all_pieces.size() > 0:
		#var random_piece = all_pieces.pick_random()
		#random_piece.activate()
		#print("Activated spike piece at:", random_piece.global_position)

func spawn_spike_pieces():
	var all_pieces = get_tree().get_nodes_in_group("SpikePieces")
	print("Found ", all_pieces.size(), " spike pieces in the scene")
	
	if all_pieces.size() > 0:
		var activation_radius = 200.0  # Adjust this value as needed
		var pieces_activated = 0
		
		for piece in all_pieces:
			var distance = piece.global_position.distance_to(hit_position)
			if distance <= activation_radius:
				piece.activate()
				pieces_activated += 1
				print("Activated spike piece at:", piece.global_position, " (distance: ", distance, ")")
		
		print("Activated ", pieces_activated, " spike pieces within radius ", activation_radius)
	else:
		print("No spike pieces found in the SpikePieces group")
