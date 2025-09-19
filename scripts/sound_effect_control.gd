# scriptor : Liew Zhen Yang
# studentID : 2302645
# function : controls the volume of the sound effects
extends HSlider

@export var bus_name: String = "Master"   
@export var session_key: String = "session_sfx" # Keep value for this session only (not saved to disk)
# Default volume (100% = 1.0)
@export var default_vol: float = 1.0            

var bus_id: int = -1

func _ready() -> void:
	bus_id = AudioServer.get_bus_index(bus_name)

	# Load session volume (or use default)
	var v: float = default_vol
	if Engine.has_meta(session_key):
		v = float(Engine.get_meta(session_key))
	else:
		Engine.set_meta(session_key, default_vol)

	# Sync the slider and apply the volume
	value = v
	_apply(v)

func _on_value_changed(v: float) -> void:
	# Update session value (survives scene changes; resets on game restart)
	Engine.set_meta(session_key, v)
	_apply(v)
	print(value)

func _apply(v: float) -> void:
	# Clamp to avoid log(0) -> -inf and convert linear 0..1 to dB
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(clamp(v, 0.0001, 1.0)))
