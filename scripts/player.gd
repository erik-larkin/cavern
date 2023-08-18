extends CharacterBody2D

signal bubble_blown(spawn_position, direction)
signal bubble_popped(bubble)

@export var _animation_tree_path : NodePath
@export var _maximum_health : int = 3

@export_group("Ground Properties")
@export var _ground_top_speed : float = 300
@export_exp_easing var _ground_acceleration : float = 100
@export_exp_easing("attenuation") var _ground_deceleration : float = 50

@export_group("Air Properties")
@export var _air_top_speed : float = 350
@export_exp_easing var _air_acceleration : float = 30
@export_exp_easing("attenuation") var _air_deceleration : float = 10
@export var _jump_speed : float = 500

@export_group("Bubble Properties")
@export var _bubble_push_force : float = 300
@export var _bubble_blow_cooldown : float =  0.5

@export_group("Hitstun Properties")
@export var _hitstun_time : float = 0.3
@export var _hit_invincibility_time : float = 1


@onready var _animation_tree = get_node(_animation_tree_path)
@onready var _current_health = _maximum_health

var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction_facing = Vector2.LEFT
var _can_blow_bubble = true
var _in_hitstun = false
var _invincible = false

const _HITSTOP_DURATION : float = 0.45
const _HITSTOP_TIMESCALE : float = 0.05
const _HIT_SHAKE_INTENSITY : float = 100

func _ready():
	_animation_tree.active = true
	$SpriteAnimationPlayer.get_animation("hurt").length = _hitstun_time


func _process(_delta):
	if Input.is_action_just_pressed("blow") and _can_blow_bubble and not _in_hitstun:
		blow_bubble()


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += _gravity * delta

	if Input.is_action_just_pressed("jump") and can_jump():
		jump()
	
	var input_direction = Input.get_axis("move_left", "move_right")

	if input_direction and not _in_hitstun:
		var acceleration = _ground_acceleration if is_on_floor() else _air_acceleration
		var top_speed = input_direction * (_ground_top_speed if is_on_floor() else _air_top_speed)
		velocity.x = move_toward(velocity.x, top_speed, acceleration)
		
		if is_on_floor():
			set_direction(input_direction)
	else:
		var deceleration = _ground_deceleration if is_on_floor() else _air_deceleration
		velocity.x = move_toward(velocity.x, 0, deceleration)
	
	if move_and_slide():
		push_bubbles()


func take_damage(amount : int) -> void:
	if not _invincible:
		_animation_tree.set("parameters/conditions/is_hurt", true)
		_current_health -= amount
		
		if _current_health <= 0:
			die()
		else:
			apply_hitstun()


func die() -> void:
	_invincible = true
	_in_hitstun = true
	set_collision_mask_value(6, false)
	velocity = Vector2.ZERO
	jump()


func apply_hitstun() -> void:
	_in_hitstun = true
	
	$EffectsAnimationPlayer.speed_scale = 1 / _HITSTOP_TIMESCALE
	$EffectsAnimationPlayer.play("shake")
	await Slowdown.apply_hitstop(_HITSTOP_DURATION, _HITSTOP_TIMESCALE)
	$EffectsAnimationPlayer.speed_scale = 1
	
	velocity.x = (_direction_facing * -1 * 500).x
	apply_invincibility_time(_hit_invincibility_time)

	get_tree().create_timer(_hitstun_time).timeout.connect(
		func(): _in_hitstun = false
	)


func apply_invincibility_time(seconds : float):
	_invincible = true
	$EffectsAnimationPlayer.play("invincibility_blink")
	get_tree().create_timer(seconds).timeout.connect(
		func(): 
			_invincible = false
			$EffectsAnimationPlayer.play("RESET")
	)


func set_direction(input_direction : int) -> void:
	_direction_facing = Vector2(input_direction, 0)
	$Sprite.flip_h = _direction_facing == Vector2.RIGHT
	$Hitboxes.scale.x = input_direction * -1
	
	
func push_bubbles() -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody2D:
			collider.apply_force(_direction_facing * _bubble_push_force)


func blow_bubble() -> void:
	$SFX/Blow.play()
	$BubbleBlowCooldownTimer.start(_bubble_blow_cooldown)
	_animation_tree.set("parameters/conditions/blowing_bubble", true)
	_can_blow_bubble = false
	bubble_blown.emit(position, _direction_facing)


func can_jump() -> bool:
	return is_on_floor() and not _in_hitstun


func jump() -> void:
	$SFX/Jump.play()
	velocity.y = -_jump_speed


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
	take_damage(1)
