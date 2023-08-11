extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = 500.0

var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction_facing = Vector2.LEFT
@onready var animation_tree = $AnimationTree


func _ready():
	pass


func _process(delta):
	update_animation_parameters()
	if randi_range(1, 100) == 1:
		ready_jump()


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += _gravity * delta

	velocity.x = _direction_facing.x * SPEED

	if move_and_slide():
		var collider = get_last_slide_collision().get_collider()
		if collider is StaticBody2D:
			change_direction()


func ready_jump() -> void:
	animation_tree.set("parameters/conditions/is_jumping", true)


func change_direction():
	_direction_facing *= -1
	$Sprite2D.flip_h = not $Sprite2D.flip_h


func jump() -> void:
	animation_tree.set("parameters/conditions/is_jumping", false)
	if is_on_floor():
		velocity.y = -JUMP_VELOCITY


func update_animation_parameters() -> void:
	animation_tree.set("parameters/conditions/is_idle", 
		is_on_floor() and velocity == Vector2.ZERO)
	
	animation_tree.set("parameters/conditions/is_in_air",
		not is_on_floor())
	
	animation_tree.set("parameters/conditions/is_landing",
		is_on_floor_only())
	
	animation_tree.set("parameters/conditions/is_moving",
		velocity.x != 0)
	
	animation_tree.set("parameters/In Air/blend_position",
		abs(velocity.y))


