#Name: Dilan Rhaj
#StudentID: 2300088

extends Area2D

@export var lifetime: float = 3.0

func _ready() -> void:
	print("=== SPIKE PIECES INITIALIZED ===")
	print("Position: ", global_position)
	
	# Start invisible & disabled by default
	visible = false
	monitoring = false
	monitorable = false

func activate() -> void:
	print("Spike pieces activated!")
	visible = true
	monitoring = true
	monitorable = true

	# Start the lifetime timer
	await get_tree().create_timer(lifetime).timeout
	print("Spike pieces lifetime ended, removing")
	queue_free()

func _on_body_entered(body: Node) -> void:
	print("Spike piece touched:", body.name)
	if body.is_in_group("Player"):
		print("Spike pieces hit player, killing...")
		if body.has_method("die"):
			body.die()
		queue_free()
