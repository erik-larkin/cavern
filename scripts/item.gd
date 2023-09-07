class_name Item

extends Node2D

signal collected(type : Types)

enum Types {APPLE, HEART, LEMON, LIFE, RASPBERRY}

var _type_weights = [15, 10, 30, 5, 50]
var _type : Types

# Called when the node enters the scene tree for the first time.
func _ready():
	_type = choose_type()
	set_animation()


func choose_type() -> Types:
	var weight_sum = 0.0
	for weight in _type_weights:
		weight_sum += weight
	
	var remaining_distance = randf() * weight_sum
	for i in _type_weights.size():
		remaining_distance -= _type_weights[i]
		if remaining_distance < 0:
			return i
	
	return 0


func set_animation() -> void:
	var animation : String = ""
	
	match (_type): 
		Types.HEART:
			animation = "heart"
		Types.LEMON:
			animation = "lemon"
		Types.LIFE:
			animation = "life"
		Types.RASPBERRY:
			animation = "raspberry"
		Types.APPLE:
			animation = "apple"
	
	$AnimationPlayer.play(animation)


func _on_hitbox_body_entered(_body):
	if visible:
		visible = false
		collected.emit(_type)
		$CollectSound.play()
		$CollectSound.finished.connect(queue_free)


