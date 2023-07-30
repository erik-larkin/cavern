extends RigidBody2D

enum Layers {PLAYER = 2, ENEMIES = 3, CAPTURE_BUBBLES = 5, FLOAT_BUBBLES = 7}
enum State {FLOAT, CAPTURE}

const CAPTURE_BUBBLE_SCALE = 0.3
const FLOAT_BUBBLE_SCALE = 0.8

@export var SPAWN_SPEED = 700
var state : State

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_state_capture():
	linear_velocity *= SPAWN_SPEED
	state = State.CAPTURE
	$AnimatedSprite2D.scale = Vector2(CAPTURE_BUBBLE_SCALE, CAPTURE_BUBBLE_SCALE)
	set_collision_mask_value(Layers.PLAYER, false)
	set_collision_mask_value(Layers.FLOAT_BUBBLES, false)
	set_collision_mask_value(Layers.ENEMIES, true)
	set_collision_layer_value(Layers.CAPTURE_BUBBLES, true)
	set_collision_layer_value(Layers.FLOAT_BUBBLES, false)


func set_state_float():
	$AnimatedSprite2D.scale = Vector2(FLOAT_BUBBLE_SCALE, FLOAT_BUBBLE_SCALE)
	linear_velocity = Vector2.ZERO
	state = State.FLOAT
	set_collision_mask_value(Layers.PLAYER, true)
	set_collision_mask_value(Layers.FLOAT_BUBBLES, true)
	set_collision_mask_value(Layers.ENEMIES, false)
	set_collision_layer_value(Layers.CAPTURE_BUBBLES, false)
	set_collision_layer_value(Layers.FLOAT_BUBBLES, true)


func _on_capture_state_timer_timeout():
	set_state_float()
