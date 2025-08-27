extends Node2D

@export var fall_speed: float = 600.0
var is_falling: bool = false

@onready var hitbox: Area2D = $Area2D
@onready var player_detect: Area2D = $PlayerDetect

func _ready() -> void:
	# Connect signals for detection and hitbox
	hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))
	player_detect.connect("body_entered", Callable(self, "_on_player_detect_body_entered"))

func _process(delta: float) -> void:
	# Move spike down if falling
	if is_falling:
		position.y += fall_speed * delta

func _on_player_detect_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		start_falling()

func _on_hitbox_body_entered(body: Node) -> void:
	# Kill only if the spike is already falling
	if body.is_in_group("Player"):
		body.die()

func start_falling() -> void:
	if not is_falling:
		is_falling = true
