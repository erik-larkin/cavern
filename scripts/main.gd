extends Node2D

var BUBBLE_SCENE = preload("res://scenes/bubble.tscn")
const CHAIN_REACTION_POP_TIME : float = 0.03

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
	
	var timer = create_timer(CHAIN_REACTION_POP_TIME)
	timer.timeout.connect(func():
		for adjacent_bubble in bubbles_to_pop:
			if adjacent_bubble != null and adjacent_bubble.has_method("pop"):
				recursive_bubble_pop(adjacent_bubble, popped)
	)


# Creates and starts a timer that runs for a given time. The timer will be freed
# automatically upon its timeout.
func create_timer(wait_time : float) -> Timer:
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = wait_time
	add_child(timer)
	timer.timeout.connect(timer.queue_free)
	return timer

