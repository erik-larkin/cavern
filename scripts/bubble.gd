extends RigidBody2D

enum Layers { OUTER_WALLS = 1, BUBBLES = 5 }

@export var _SPAWN_SPEED = 700.0
@export var _CAPTURE_TIME = 0.4
@export var _POP_TIME = 8.0
@export var _animation_tree_path : NodePath

@onready var _animation_tree = get_node(_animation_tree_path)


func init(start_position : Vector2, move_direction : Vector2):
	position = start_position
	linear_velocity = _SPAWN_SPEED * move_direction.normalized()


func _ready():
	set_collision_layer_value(Layers.BUBBLES, false)
	set_collision_mask_value(Layers.BUBBLES, false)
	_animation_tree.active = true
	$AnimationPlayer.get_animation("spawn").length = _CAPTURE_TIME
	$PopTimer.wait_time = _POP_TIME
	get_tree().create_timer(_CAPTURE_TIME).timeout.connect(start_floating)


func _process(_delta):
	if _animation_tree.get("parameters/conditions/is_floating"):
		var time_scale = _POP_TIME / $PopTimer.time_left
		_animation_tree.set("parameters/float/TimeScale/scale", time_scale)


func start_floating():
	_animation_tree.set("parameters/conditions/is_floating", true)
	linear_velocity = Vector2.ZERO
	set_collision_layer_value(Layers.BUBBLES, true)
	set_collision_mask_value(Layers.BUBBLES, true)


func pop():
	_animation_tree.set("parameters/conditions/is_popping", true)
	set_collision_layer_value(Layers.BUBBLES, false)
	linear_velocity = Vector2.ZERO
	
	var pop_animation : Animation = $AnimationPlayer.get_animation("pop")
	if pop_animation:
		get_tree().create_timer(pop_animation.length).timeout.connect(
			queue_free)
	else:
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_pop_timer_timeout():
	pop()


func _on_body_entered(body):
	if body.collision_layer == Layers.OUTER_WALLS:
		start_floating()
