extends RigidBody2D

enum Layers { OUTER_WALLS = 1, ENEMIES = 3, BUBBLES = 5 }
enum State {FLOAT, CAPTURE, POPPING, ENEMY}

const CAPTURE_BUBBLE_SCALE = 0.4
const FLOAT_BUBBLE_SCALE = 0.8

@export var SPAWN_SPEED = 700
var state : State


func set_state_capture():
	linear_velocity *= SPAWN_SPEED
	state = State.CAPTURE
	$AnimatedSprite.play("default")
	$AnimatedSprite.scale = Vector2(CAPTURE_BUBBLE_SCALE, CAPTURE_BUBBLE_SCALE)
	set_collision_layer_value(Layers.BUBBLES, false)
	set_collision_mask_value(Layers.BUBBLES, false)


func set_state_float():
	linear_velocity = Vector2.ZERO
	state = State.FLOAT
	$AnimatedSprite.play("default")
	$AnimatedSprite.scale = Vector2(FLOAT_BUBBLE_SCALE, FLOAT_BUBBLE_SCALE)
	set_collision_layer_value(Layers.BUBBLES, true)
	set_collision_mask_value(Layers.BUBBLES, true)


func pop():
	if state == State.FLOAT:
		set_collision_layer_value(Layers.BUBBLES, false)
		state = State.POPPING
		linear_velocity = Vector2.ZERO
		$PopSound.play()
		$AnimatedSprite.play("pop")


func _on_capture_state_timer_timeout():
	set_state_float()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_pop_timer_timeout():
	pop()


func _on_animated_sprite_2d_animation_finished():
	if state == State.POPPING:
		queue_free()


func _on_body_entered(body):
	if body.collision_layer == Layers.OUTER_WALLS and state == State.CAPTURE:
		set_state_float()
