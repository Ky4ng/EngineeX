# scriptor : Liew Zhen Yang
# studentID : 2302645
# key that storing volume :  META_KEY
#default volume is 100% = 1.0 
#function : control the volumn , if had volumnn is session then used it else used default volumn
#         : store slider value to meta data, just only store in memory, not the disk and print the value
#         : set volumn, turn linear volumn (0.0 - 1.0) into db, and avoid v= 0 occur -inf


extends HSlider

@export var audio_bus_name: String = "Master"
var audio_bus_id: int

# Key for storing volume during the current session
const META_KEY := "session_music_volume"  
# Default volume (100% = 1.0)
const DEFAULT_VOL := 1.0               

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

	# Load the volume from the current session; if none exists, use the default (1.0)
	var v: float = DEFAULT_VOL
	if Engine.has_meta(META_KEY):
		v = float(Engine.get_meta(META_KEY))
	else:
		Engine.set_meta(META_KEY, DEFAULT_VOL)

	# Sync the slider and apply the volume
	value = v
	_apply_volume(v)

func _on_value_changed(v: float):
	 # Only store in memory only (not saved to disk)
	Engine.set_meta(META_KEY, v)   
	_apply_volume(v)
	print(value)

func _apply_volume(v: float):
	# Prevent log(0) → -inf
	var db := linear_to_db(clamp(v, 0.0001, 1.0))
	AudioServer.set_bus_volume_db(audio_bus_id, db)
