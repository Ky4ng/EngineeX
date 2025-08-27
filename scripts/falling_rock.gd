extends Node2D

@export var fall_speed: float =  300.0 #speed of falling

var is_falling: bool = false #is rock currently falling

@onready var killbox = $Killbox
@onready var trigger_area = $TriggerArea
@onready var self_destruct_timer = $SelfDestructTimer #for self destruction (so it's not falling forever)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var current_level = get_current_level()

	if current_level >= 1 and current_level <= 3:
		sprite.play("moon")
	elif current_level >= 4 and current_level <= 6:
		sprite.play("cave")
	else:
		sprite.play("spaceship")
	
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

func get_current_level() -> int:
	var current_scene_path = get_tree().current_scene.scene_file_path
	var scene_name = current_scene_path.get_file().get_basename()

	var regex = RegEx.new()
	regex.compile("\\d+$")  # match digits at the end
	var result = regex.search(scene_name)

	if result:
		return int(result.get_string())
	else:
		return 0  # fallback if no number found
