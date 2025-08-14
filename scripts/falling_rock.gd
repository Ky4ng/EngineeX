extends Node2D

@export var fall_speed: float =  180.0 #speed of falling

var is_falling: bool = false #is rock currently falling

@onready var killbox = $Killbox
@onready var trigger_area = $TriggerArea
@onready var self_destruct_timer = $SelfDestructTimer #for self destruction (so it's not falling forever)

func _physics_process(delta: float) -> void:
	if is_falling:
		global_position.y += fall_speed * delta
		
func _on_trigger_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#print("Player detected. Rock gonna fall!")
		is_falling = true
		self_destruct_timer.start()
		
func _on_killbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#print("Player hit by rock. Reset Level!")
		body.die()
		
func _on_self_destruct_timer_timeout() -> void:
	#print("Rock removed from the Scene!")
	queue_free()

func reset_level():
	get_tree().reload_current_scene()
