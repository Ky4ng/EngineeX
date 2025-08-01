extends Node2D

var player: CharacterBody2D
var launch_count := 0
const MAX_LAUNCHES := 3
var mouse_was_pressed := false
var can_launch := true
var is_reloading := false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	for node in get_tree().get_root().get_children():
		if node.has_node("Player"):
			player = node.get_node("Player") as CharacterBody2D

	# Add a Timer node for reloadingSSS
	var reload_timer = Timer.new()
	reload_timer.wait_time = 0.5
	reload_timer.one_shot = true
	reload_timer.name = "ReloadTimer"
	add_child(reload_timer)
	reload_timer.connect("timeout", Callable(self, "_on_reload_timer_timeout"))

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	rotation = (mouse_pos - global_position).angle() + deg_to_rad(90)

	var mouse_now = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if mouse_now and not mouse_was_pressed and launch_count < MAX_LAUNCHES and can_launch:
		if player and player.has_method("apply_launch"):
			var direction = (mouse_pos - player.global_position).normalized()
			var force = -direction * 900.0
			player.apply_launch(force)
			launch_count += 1
			print("Launch", launch_count,)
		sprite.play("fire")


	mouse_was_pressed = mouse_now

	# Manual reload with R key — can reload anytime now
	if Input.is_action_just_pressed("reload") and not is_reloading:
		is_reloading = true
		can_launch = false
		print("Reloading")
		get_node("ReloadTimer").start()

func _on_reload_timer_timeout():
	launch_count = 0
	can_launch = true
	is_reloading = false
	print("Reloaded")
