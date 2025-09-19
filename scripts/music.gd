extends AudioStreamPlayer2D

@export var menu_music: AudioStream
@export var moon_music: AudioStream
@export var cave_music: AudioStream
@export var spaceship_music: AudioStream
@export var vitory_music: AudioStream
var last_scene: Node = null

func _ready():
	var root = get_tree().get_root()

	if root.has_node("MusicPlayer") and self != root.get_node("MusicPlayer"):
		queue_free()
		return

	if get_parent() != root:
		get_parent().call_deferred("remove_child", self)
		root.call_deferred("add_child", self)

	name = "MusicPlayer"
	owner = null

	# Watch for tree changes (fires on scene changes too)
	get_tree().connect("tree_changed", Callable(self, "_on_tree_changed"))

	# Run once for starting scene
	call_deferred("update_music_for_level")


func _on_tree_changed():
	# Defer scene check so current_scene is valid
	call_deferred("_check_scene_change")


func _check_scene_change():
	var current_scene = get_tree().current_scene
	if current_scene and current_scene != last_scene:
		last_scene = current_scene
		update_music_for_level()


func update_music_for_level():
	var current_scene = get_tree().current_scene
	if not current_scene:
		return

	var current_scene_path = current_scene.scene_file_path
	var scene_name = current_scene_path.get_file().get_basename().to_lower()

	print("🎬 Current scene:", scene_name)

	var new_stream: AudioStream = null

	if scene_name.contains("main_menu") or scene_name.contains("level_select"):
		print("🎵 Picking menu music")
		new_stream = menu_music
	else:
		var current_level = get_current_level(scene_name)
		print("📊 Detected level number:", current_level)

		if current_level >= 1 and current_level <= 3:
			print("🎵 Picking moon music")
			new_stream = moon_music
		elif current_level >= 4 and current_level <= 6:
			print("🎵 Picking cave music")
			new_stream = cave_music
		elif current_level >= 7 and current_level <= 10:
			print("🎵 Picking spaceship music")
			new_stream = spaceship_music
		else:
			print("🎵 Picking vitory music")
			new_stream = vitory_music

	if stream != new_stream:
		stream = new_stream
		if stream:
			stream.loop = true
			play()
			print("▶️ Now playing new track")
	else:
		print("⏩ Music unchanged")


func get_current_level(scene_name: String) -> int:
	var regex = RegEx.new()
	regex.compile("\\d+$")
	var result = regex.search(scene_name)
	return int(result.get_string()) if result else 0
