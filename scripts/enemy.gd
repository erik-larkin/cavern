extends CharacterBody2D


@export var _SPEED = 150.0
@export var _JUMP_VELOCITY = 500.0
@export var _animation_tree_path : NodePath

@onready var _animation_tree : AnimationTree = get_node(_animation_tree_path)

var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction_facing = Vector2.LEFT


func _ready():
	_animation_tree.active = true


func _process(delta):
	_animation_tree.set("parameters/In Air/blend_position", abs(velocity.y))
	
	if randi_range(1, 100) == 1:
		ready_jump()


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += _gravity * delta

	velocity.x = _direction_facing.x * _SPEED

	if move_and_slide():
		var collider = get_last_slide_collision().get_collider()
		if collider is StaticBody2D:
			change_direction()


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
	if is_on_floor():
		velocity.y = -_JUMP_VELOCITY
