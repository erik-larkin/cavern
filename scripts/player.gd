extends CharacterBody2D

signal bubble_blown(spawn_position, direction)
signal bubble_popped(bubble)

@export var _WALK_SPEED : float
@export var _ground_deceleration : float
@export var _air_deceleration : float
@export var _JUMP_SPEED : float
@export var _BUBBLE_PUSH_FORCE : float
@export var _BUBBLE_BLOW_COOLDOWN : float
@export var _hitstun_time : float
@export var _animation_tree_path : NodePath

@onready var _animation_tree = get_node(_animation_tree_path)

var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction_facing = Vector2.LEFT
var _can_blow_bubble = true
var _in_hitstun = false


func _ready():
	_animation_tree.active = true
	$AnimationPlayer.get_animation("hurt").length = _hitstun_time


func _process(_delta):
	if Input.is_action_just_pressed("blow") and _can_blow_bubble:
		blow_bubble()
	


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += _gravity * delta

	if Input.is_action_just_pressed("jump") and can_jump():
		jump()
	
	var input_direction = Input.get_axis("move_left", "move_right")

	if input_direction and not _in_hitstun:
		velocity.x = input_direction * _WALK_SPEED
		if is_on_floor():
			set_direction(input_direction)
	else:
		var deceleration = _ground_deceleration if is_on_floor() else _air_deceleration
		velocity.x = move_toward(velocity.x, 0, deceleration)
	
	if move_and_slide():
		push_bubbles()


func take_damage() -> void:
	_animation_tree.set("parameters/conditions/is_hurt", true)
	_in_hitstun = true
	velocity.x = (_direction_facing * -1 * 500).x
	
	get_tree().create_timer(_hitstun_time).timeout.connect(
		func(): _in_hitstun = false
	)


func set_direction(input_direction : int) -> void:
	_direction_facing = Vector2(input_direction, 0)
	$Sprite.flip_h = _direction_facing == Vector2.RIGHT
	$Hitboxes.scale.x = input_direction * -1
	
	
func push_bubbles() -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody2D:
			collider.apply_force(_direction_facing * _BUBBLE_PUSH_FORCE)


func blow_bubble() -> void:
	$SFX/Blow.play()
	$BubbleBlowCooldownTimer.start(_BUBBLE_BLOW_COOLDOWN)
	_animation_tree.set("parameters/conditions/blowing_bubble", true)
	_can_blow_bubble = false
	bubble_blown.emit(position, _direction_facing)


func can_jump() -> bool:
	return is_on_floor()


func jump() -> void:
	$SFX/Jump.play()
	velocity.y = -_JUMP_SPEED


func _on_bubble_blow_cooldown_timer_timeout() -> void:
	_can_blow_bubble = true


func _on_bubble_bounce_hitbox_area_entered(area):
	if Input.is_action_pressed("jump") and velocity.y > 0:
		jump()


func _on_animation_tree_animation_finished(anim_name) -> void:
	var parameter_name : String = ""
	
	match anim_name:
		"blow": parameter_name = "blowing_bubble"
		"hurt": parameter_name = "is_hurt"
		_: return

	_animation_tree.set("parameters/conditions/" + parameter_name, false)


func _on_hurtbox_body_entered(body):
	take_damage()
