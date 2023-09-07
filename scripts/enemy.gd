extends CharacterBody2D

class_name Enemy

signal exploded(enemy_position : Vector2)

@export var _SPEED : float
@export var _JUMP_VELOCITY : float
@export var _terminal_velocity : float = 700
@export var _animation_tree_path : NodePath

@onready var _animation_tree : AnimationTree = get_node(_animation_tree_path)
@onready var _TEXTURE_HEIGHT = $Sprite.texture.get_height() * 0.7

var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction_facing := Vector2.LEFT
var _is_in_bubble := false
var _is_dying := false

const _ENEMIES_LAYER := 3

func _ready():
	_animation_tree.active = true


func _process(_delta):
	_animation_tree.set("parameters/In Air/blend_position", abs(velocity.y))


func _physics_process(delta):
	if _is_dying:
		fall_and_explode(delta)
	elif not _is_in_bubble:
		process_ai(delta)


func get_captured_by_bubble() -> void:
	_is_in_bubble = true
	velocity = Vector2.ZERO
	$SFX/Hit.play()
	$NormalCollisionShape.set_deferred("disabled", true)
	set_collision_layer_value(_ENEMIES_LAYER, false)


func escape_bubble() -> void:
	_is_in_bubble = false
	velocity = Vector2.ZERO
	$NormalCollisionShape.set_deferred("disabled", false)
	set_collision_layer_value(_ENEMIES_LAYER, true)


func fall_and_explode(delta) -> void:
	apply_gravity(delta)
	
	move_and_slide()
	
	if is_on_floor():
		exploded.emit(position)
		queue_free()


func process_ai(delta) -> void:
	apply_gravity(delta)
	velocity.x = _direction_facing.x * _SPEED

	if move_and_slide() and collision_with_outer_walls():
		change_direction()
	
	position.y = wrapf(position.y, -(_TEXTURE_HEIGHT / 2), 
		get_viewport_rect().size.y + (_TEXTURE_HEIGHT / 2))
	
	if randi_range(1, 100) == 1 and is_on_floor():
		ready_jump()


func collision_with_outer_walls() -> bool:
	return get_last_slide_collision().get_collider() is StaticBody2D


func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity.y = clamp(velocity.y + (_gravity * delta), 
			-_terminal_velocity, _terminal_velocity)


func ready_jump() -> void:
	_animation_tree.set("parameters/conditions/is_jumping", true)
	
	var jump_animation : Animation = $AnimationPlayer.get_animation("jump")
	if jump_animation:
		get_tree().create_timer(jump_animation.length).timeout.connect(jump)
	else:
		jump()


func change_direction() -> void:
	_direction_facing *= -1
	$Sprite.flip_h = not $Sprite.flip_h


func jump() -> void:
	_animation_tree.set("parameters/conditions/is_jumping", false)
	if is_on_floor() and not _is_in_bubble:
		$SFX/Jump.play()
		velocity.y = -_JUMP_VELOCITY


func die() -> void:
	_is_in_bubble = false
	_is_dying = true
	var death_launch_push = Vector2(0, -randf_range(680, 720))
	velocity += death_launch_push.rotated(randf_range(-PI / 4, PI / 4))
	$SFX/Hit.pitch_scale *= 0.25
	$SFX/Hit.play()
	remove_child($NormalCollisionShape)
