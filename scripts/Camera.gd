extends Camera2D

@export var SHAKE_DECAY_RATE : float = 5.0 

var shake_strength : float = 0.0


func _process(delta):
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	offset = Vector2(randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength))


func apply_shake(strength : float) -> void:
	shake_strength = strength

