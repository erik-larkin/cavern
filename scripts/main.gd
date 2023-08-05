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
	$Bubbles.add_child(bubble_instance)


func _on_player_bubble_popped(bubble):
	var popped : Array[RigidBody2D] = []
	recursive_bubble_pop(bubble, popped)


# DFS algorithm to pop all adjacent bubbles
func recursive_bubble_pop(bubble : RigidBody2D, popped : Array[RigidBody2D]):
	if bubble in popped:
		return
	
	var bubbles_to_pop = bubble.get_colliding_bodies()
	bubble.pop()
	popped.append(bubble)
	
	for adjacent_bubble in bubbles_to_pop:
		if adjacent_bubble.has_method("pop"):
			recursive_bubble_pop(adjacent_bubble, popped)
