extends Node2D

@export var BULLET: PackedScene = null
@export var FIRE_RATE: float = 0.2  # Shots per second

var target: Node2D = null

@onready var gunSprite = $GunSprite
@onready var rayCast = $RayCast2D
@onready var reloadTimer = $RayCast2D/ReloadTimer

func _ready():
	reloadTimer.wait_time = 0.1 / FIRE_RATE
	reloadTimer.one_shot = true  # ensure it's one-shot
	await get_tree().process_frame
	target = find_target()

func _physics_process(_delta):
	# Continuously look for target
	if target == null or not is_instance_valid(target):
		target = find_target()
		return

	if target != null:
		var angle_to_target: float = global_position.direction_to(target.global_position).angle()
		rayCast.global_rotation = angle_to_target
		gunSprite.rotation = angle_to_target

		if rayCast.is_colliding() and rayCast.get_collider().is_in_group("Player"):
			if reloadTimer.is_stopped():
				shoot()

func shoot():
	print("PEW")
	
	if BULLET:
		var bullet: Node2D = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		bullet.global_rotation = rayCast.global_rotation

	reloadTimer.start()

func find_target():
	if get_tree().has_group("Player") and get_tree().get_nodes_in_group("Player").size() > 0:
		return get_tree().get_nodes_in_group("Player")[0]
	return null

func _on_reload_timer_timeout():
	# Check again if still seeing player
	if rayCast.is_colliding() and rayCast.get_collider().is_in_group("Player"):
		shoot()
