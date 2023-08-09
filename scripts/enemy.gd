extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = 500.0

var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction_facing = Vector2.LEFT

enum State {IDLE, MOVE, IN_AIR, WINDUP, SHOOT}

var _state: State:
	set(new_state):
		if new_state != _state:
			_state = new_state
			set_animation(_state)


var _winding_up_jump : bool = false
var _on_ground : bool = false


func _ready():
	pass


func _process(delta):
	if randi_range(1, 100) == 1 and is_on_floor():
		wind_up_jump()

	update_state()
	if _state == State.IN_AIR:
		set_animation(_state)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += _gravity * delta

	velocity.x = _direction_facing.x * SPEED

	if move_and_slide():
		var collider = get_last_slide_collision().get_collider()
		if collider is StaticBody2D:
			change_direction()


func change_direction():
	_direction_facing *= -1
	$Sprite.flip_h = not $Sprite.flip_h


func update_state() -> void:
	if not is_on_floor():
		_state = State.IN_AIR
	elif _winding_up_jump:
		_state = State.WINDUP
	elif velocity.x != 0:
		_state = State.MOVE
	else:
		_state = State.IDLE


func set_animation(state : State) -> void:
	match state:
		State.IN_AIR:
			choose_air_frame_based_on_speed()
		State.WINDUP:
			$Sprite.play("windup")
		State.SHOOT:
			$Sprite.play("shoot")
		State.MOVE, _:
			$Sprite.play("move")


func choose_air_frame_based_on_speed():
	$Sprite.animation = "jump_and_fall"
	var absolute_velocity = abs(velocity.y)
	
	if absolute_velocity >= 250:
		$Sprite.frame = 3
	elif absolute_velocity >= 150:
		$Sprite.frame = 2
	elif absolute_velocity >= 50:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0


func wind_up_jump() -> void:
	_winding_up_jump = true


func jump() -> void:
	if is_on_floor():
		velocity.y = -JUMP_VELOCITY


func _on_sprite_animation_finished():
	if $Sprite.animation == "windup" and _winding_up_jump:
		_winding_up_jump = false
		jump()
