extends Node2D

@export var BULLET: PackedScene
@export var FIRE_RATE: float = 0.2  # Shots per second

@onready var gunSprite = $GunSprite
@onready var rayCast = $RayCast2D
@onready var reloadTimer = $RayCast2D/ReloadTimer
@onready var turret_sound: AudioStreamPlayer2D = $TurretSound

func _ready():
	reloadTimer.wait_time = 0.1 / FIRE_RATE
	reloadTimer.one_shot = true

func _physics_process(_delta):
	var player = get_nearest_player()
	if player == null:
		return

	# Rotate gun & raycast towards player
	var angle_to_player: float = global_position.direction_to(player.global_position).angle()
	rayCast.global_rotation = angle_to_player
	gunSprite.rotation = angle_to_player

	# Shoot only if raycast sees player
	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		if collider and collider.is_in_group("Player"):
			if reloadTimer.is_stopped():
				shoot()

func shoot():
	print("PEW")
	if BULLET:
		var bullet: Node2D = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		bullet.global_rotation = rayCast.global_rotation

	# 🔊 play sound when shooting
	if turret_sound:
		turret_sound.play()

	reloadTimer.start()

func get_nearest_player() -> Node2D:
	if not get_tree().has_group("Player"):
		return null
	var players = get_tree().get_nodes_in_group("Player")
	if players.is_empty():
		return null
	
	var nearest = players[0]
	var nearest_dist = global_position.distance_to(nearest.global_position)

	for p in players:
		var dist = global_position.distance_to(p.global_position)
		if dist < nearest_dist:
			nearest = p
			nearest_dist = dist
	return nearest

func _on_reload_timer_timeout():
	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		if collider and collider.is_in_group("Player"):
			shoot()
