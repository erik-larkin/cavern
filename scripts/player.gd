extends CharacterBody2D

signal bubble_blown(spawn_position, direction)
signal bubble_popped(bubble)

@export var WALK_SPEED : float
@export var JUMP_SPEED : float
@export var BUBBLE_PUSH_FORCE : float
@export var BUBBLE_BLOW_COOLDOWN : float

@onready var animation_tree = $AnimationPlayer/AnimationTree

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction_facing = Vector2.LEFT
var can_blow_bubble = true



func _ready():
	animation_tree.active = true
	$AnimationPlayer.get_animation("blow").length = BUBBLE_BLOW_COOLDOWN


func _process(_delta):
	if Input.is_action_just_pressed("blow") and can_blow_bubble:
		blow_bubble()


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and can_jump():
		jump()
	
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		velocity.x = input_direction * WALK_SPEED
		if is_on_floor():
			set_direction(input_direction)
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
	
	if move_and_slide():
		push_bubbles()


func set_direction(input_direction : int) -> void:
	direction_facing = Vector2(input_direction, 0)
	$Sprite.flip_h = direction_facing == Vector2.RIGHT
	$Hitboxes.scale.x = input_direction * -1
	
	
func push_bubbles():
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody2D:
			collider.apply_force(direction_facing * BUBBLE_PUSH_FORCE)


func blow_bubble():
	$SFX/Blow.play()
	$BubbleBlowCooldownTimer.start(BUBBLE_BLOW_COOLDOWN)
	can_blow_bubble = false
	bubble_blown.emit(position, direction_facing)


func can_jump() -> bool:
	return is_on_floor()


func jump():
	$SFX/Jump.play()
	velocity.y = -JUMP_SPEED


func _on_bubble_pop_hitbox_body_entered(body):
	bubble_popped.emit(body)


func _on_bubble_bounce_hitbox_body_entered(body):
	if Input.is_action_pressed("jump") and velocity.y > 0:
		jump()
	else:
		bubble_popped.emit(body)


func _on_bubble_blow_cooldown_timer_timeout():
	can_blow_bubble = true
