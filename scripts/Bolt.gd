extends Node2D

class_name Bolt


var _direction := Vector2.LEFT
var _speed := 300


func init(spawn_position : Vector2, direction : Vector2) -> void:
	position = spawn_position
	set_direction(direction)
	$AnimatedSprite.play("default")

func set_direction(direction : Vector2) -> void:
	_direction = direction
	$AnimatedSprite.flip_h = _direction != Vector2.LEFT


func _process(delta):
	position += (_direction * _speed) * delta
