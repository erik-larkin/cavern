extends CharacterBody2D

class_name Player

signal bubble_blown(spawn_position, direction)
signal bubble_popped(bubble)
signal health_updated(new_health : int)
signal died(lives_remaining : int)
signal hurt(damage_ratio : float)

@export var _animation_tree_path : NodePath
@export var _maximum_health : int = 3
@export var _starting_lives : int = 3
@export var SHAKE_DECAY_RATE : float = 5.0

@export_group("Ground Properties")
@export var _ground_top_speed : float = 250
@export_exp_easing var _ground_acceleration : float = 900
@export_exp_easing("attenuation") var _ground_deceleration : float = 900

@export_group("Air Properties")
@export var _air_top_speed : float = 300
@export var _terminal_velocity : float = 700
@export_exp_easing var _air_acceleration : float = 1000
@export_exp_easing("attenuation") var _air_deceleration : float = 800
@export var _jump_speed : float = 450

@export_group("Bubble Properties")
@export var _bubble_push_force : float = 1000
@export var _bubble_blow_cooldown : float =  0.5

@export_group("Hitstun Properties")
@export var _hitstun_time : float = 0.5
@export var _invincibility_time : float = 1

@onready var _TEXTURE_HEIGHT = $Sprite.texture.get_height() * 0.7
@onready var _animation_tree = get_node(_animation_tree_path)

var _current_health = _maximum_health
var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction_facing = Vector2.LEFT
var _can_blow_bubble = true
var _in_hitstun = false
var _invincible = false
var _input_direction = 0
var _lives_remaining = _starting_lives
var _shake_strength : float = 0.0


const _HITSTOP_DURATION : float = 0.4
const _HITSTOP_TIMESCALE : float = 0.05
const _HIT_SHAKE_INTENSITY : float = 100

func _ready():
	update_health(_maximum_health)
	_animation_tree.active = true
	$SpriteAnimationPlayer.get_animation("hurt").length = _hitstun_time


func _process(delta):
	if Input.is_action_just_pressed("blow") and _can_blow_bubble and not _in_hitstun:
		blow_bubble()
	
	if Input.is_action_just_pressed("kill_player"):
		take_damage(_current_health)
		
	_shake_strength = lerp(_shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	$Sprite.offset = Vector2(randf_range(-_shake_strength, _shake_strength),
		randf_range(-_shake_strength, _shake_strength))


func spawn(position : Vector2, direction : float) -> void:
	update_health(_maximum_health)
	
	set_collision_mask_value(6, true)
	set_collision_mask_value(5, true)
	
	set_direction(direction)
	self.position = position
	
	_in_hitstun = false
	_invincible = false
	
	_animation_tree.set("parameters/conditions/is_off_screen", false)


func respawn(position : Vector2, direction : float) -> void:
	spawn(position, direction)
	apply_invincibility_time(_invincibility_time * 3)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y = clamp(velocity.y + (_gravity * delta), 
			-_terminal_velocity, _terminal_velocity)

	if Input.is_action_just_pressed("jump") and can_jump():
		jump()
	
	_input_direction = Input.get_axis("move_left", "move_right")
	_animation_tree.set("parameters/run/TimeScale/scale", abs(_input_direction))

	if _input_direction and not _in_hitstun:
		var acceleration = _ground_acceleration if is_on_floor() else _air_acceleration
		var top_speed = _input_direction * (_ground_top_speed if is_on_floor() else _air_top_speed)
		velocity.x = move_toward(velocity.x, top_speed, acceleration * delta)
		
		if is_on_floor():
			set_direction(_input_direction)
	else:
		var deceleration = _ground_deceleration if is_on_floor() else _air_deceleration
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	
	if move_and_slide() and _input_direction:
		push_bubbles()
	
	if not dead():
		position.y = wrapf(position.y, -(_TEXTURE_HEIGHT / 2), 
			get_viewport_rect().size.y + (_TEXTURE_HEIGHT / 2))


func take_damage(amount : int) -> void:
	if not _invincible:
		_animation_tree.set("parameters/conditions/is_hurt", true)
		hurt.emit(float(amount) / _current_health)
		apply_shake(5.0 * float(amount) / _current_health)
		lose_health(amount)
		
		if _current_health <= 0:
			die()
		else:
			apply_hitstun()


func dead() -> bool:
	return _current_health <= 0


func gain_health(amount : int) -> void:
	update_health(_current_health + amount)


func lose_health(amount : int) -> void:
	update_health(_current_health - amount)


func update_health(new_health : int) -> void:
	_current_health = clamp(new_health, 0, _maximum_health)
	health_updated.emit(_current_health)


func die() -> void:
	await Slowdown.apply_hitstop(_HITSTOP_DURATION * 1.5, _HITSTOP_TIMESCALE)
	_in_hitstun = true
	# turn off collision with tilemap and bubbles on death
	set_collision_mask_value(6, false)
	set_collision_mask_value(5, false)
	velocity = Vector2.ZERO
	_lives_remaining -= 1
	jump()


func apply_hitstun() -> void:
	_in_hitstun = true
	await Slowdown.apply_hitstop(_HITSTOP_DURATION, _HITSTOP_TIMESCALE)
	
	velocity.x = (_direction_facing * -1 * 500).x
	apply_invincibility_time(_invincibility_time)

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


func apply_shake(strength : float) -> void:
	_shake_strength = strength


func set_direction(input_direction : float) -> void:
	_direction_facing = Vector2(input_direction, 0).normalized()
	$Sprite.flip_h = _direction_facing == Vector2.RIGHT
	$Hitboxes.scale.x = input_direction * -1
	
	
func push_bubbles() -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody2D:
			collider.apply_central_force(_direction_facing * _bubble_push_force)


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


func _on_bubble_bounce_hitbox_area_entered(_area):
	if Input.is_action_pressed("jump") and velocity.y > 0:
		jump()


func _on_animation_tree_animation_finished(anim_name) -> void:
	var parameter_name : String = ""
	
	match anim_name:
		"blow": parameter_name = "blowing_bubble"
		"hurt": parameter_name = "is_hurt"
		_: return

	_animation_tree.set("parameters/conditions/" + parameter_name, false)


func _on_hurtbox_body_entered(_body):
	if not dead():
		take_damage(1)


func _on_visible_on_screen_notifier_screen_exited():
	if (dead() and position.y > 0):
		_animation_tree.set("parameters/conditions/is_hurt", false)
		_animation_tree.set("parameters/conditions/is_off_screen", true)
		died.emit(_lives_remaining)
