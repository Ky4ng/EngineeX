# scriptor : Chua Kek Yang
# studentID : 2103936
# function: Adds a simple screen shake to Camera2D.
extends Camera2D
class_name Camera2DShake

var _shake_time: float = 0.0
var _shake_amp: float  = 0.0

func shake(amplitude: float = 6.0, duration: float = 0.35) -> void:
	_shake_amp = amplitude
	_shake_time = duration

func _process(delta: float) -> void:
	if _shake_time > 0.0:
		_shake_time -= delta
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_amp
	else:
		offset = Vector2.ZERO
