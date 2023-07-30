extends Node2D

var BUBBLE_SCENE = preload("res://scenes/bubble.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_bubble_blown(spawn_position : Vector2, direction : Vector2):
	var bubble_instance = BUBBLE_SCENE.instantiate()
	bubble_instance.position = spawn_position
	bubble_instance.linear_velocity = direction.normalized()
	bubble_instance.set_state_capture()
	add_child(bubble_instance)
	
