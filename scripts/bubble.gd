extends RigidBody2D
class_name Bubble

signal popped_by_player (bubble : RigidBody2D)
signal started_floating (bubble : RigidBody2D)

enum Layers { OUTER_WALLS = 1, ENEMIES = 3, BUBBLES = 5 }

const _SPAWN_OFFSET = 20
const _TEXTURE_HEIGHT = 41

@export var _SPAWN_SPEED : float
@export var _CAPTURE_TIME : float
@export var _POP_TIME : float
@export var _FLOAT_SPEED : float = 100
@export var _animation_tree_path : NodePath

@onready var _animation_tree = get_node(_animation_tree_path)

var _is_floating : bool = false
var _current_airflow : Vector2 = Vector2.ZERO
var _captured_enemy : Enemy = null


func init(start_position : Vector2, move_direction : Vector2):
	position = start_position + (move_direction * _SPAWN_OFFSET)
	linear_velocity = _SPAWN_SPEED * move_direction.normalized()


func _ready():
	set_collision_layer_value(Layers.BUBBLES, false)
	set_collision_mask_value(Layers.BUBBLES, false)
	
	_animation_tree.active = true
	set_spawn_animation_length()
	
	scale = Vector2(0.3, 0.3)
	$PopTimer.wait_time = _POP_TIME
	get_tree().create_timer(_CAPTURE_TIME).timeout.connect(start_floating)


func _process(_delta):
	if _animation_tree.get("parameters/conditions/is_floating"):
		var time_scale = _POP_TIME / $PopTimer.time_left
		_animation_tree.set("parameters/float/TimeScale/scale", time_scale)
	
	
	if _captured_enemy:
		_captured_enemy.position = position


func _integrate_forces(_delta):
	if _is_floating:
		apply_central_force(_current_airflow * _FLOAT_SPEED)

	position.y = wrapf(position.y, -(_TEXTURE_HEIGHT / 2), 
		get_viewport_rect().size.y + (_TEXTURE_HEIGHT / 2))


func set_spawn_animation_length() -> void:
	var length = $AnimationPlayer.get_animation("spawn").length
	var time_scale = length / _CAPTURE_TIME
	_animation_tree.set("parameters/spawn/TimeScale/scale", time_scale)


func start_floating():
	started_floating.emit(self)
	_is_floating = true
	_animation_tree.set("parameters/conditions/is_floating", true)
	linear_velocity = _current_airflow * _FLOAT_SPEED
	
	$PopTimer.start()
	set_collision_layer_value(Layers.BUBBLES, true)
	set_collision_mask_value(Layers.BUBBLES, true)
	set_collision_mask_value(Layers.ENEMIES, false)


func pop_and_defeat_enemy():
	if _captured_enemy:
		_captured_enemy.die()
		_captured_enemy = null
	
	pop()


func pop():
	if _captured_enemy:
		_captured_enemy.escape_bubble()
		_captured_enemy = null
		
	_animation_tree.set("parameters/conditions/is_popping", true)
	set_collision_layer_value(Layers.BUBBLES, false)
	linear_velocity = Vector2.ZERO
	
	var pop_animation : Animation = $AnimationPlayer.get_animation("pop")
	if pop_animation:
		get_tree().create_timer(pop_animation.length).timeout.connect(
			queue_free)
	else:
		queue_free()


func get_adjacent_bubbles() -> Array[Node2D]:
	return $Hitboxes/RecursivePopHitbox.get_overlapping_bodies()


func set_airflow_direction(airflow : Vector2) -> void:
	_current_airflow = airflow.normalized()


func capture_enemy(enemy : Enemy) -> void:
	if enemy.has_method("get_captured_by_bubble"):
		enemy.get_captured_by_bubble()
		_captured_enemy = enemy


func _on_pop_timer_timeout():
	pop()


func _on_body_entered(body):
	if not _is_floating:
		start_floating()
		if body is Enemy:
			capture_enemy(body)


func _on_pop_hitbox_area_entered(_area):
	if _is_floating:
		popped_by_player.emit(self)
