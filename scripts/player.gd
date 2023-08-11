extends CharacterBody2D

signal bubble_blown(spawn_position, direction)
signal bubble_popped(bubble)

@export var WALK_SPEED = 300.0
@export var JUMP_SPEED = 500.0
@export var PUSH_FORCE = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction_facing = Vector2.LEFT

@onready var animation_tree = $AnimationTree



func _process(_delta):
	if Input.is_action_just_pressed("blow"):
		blow_bubble()


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump"):
		jump()
	
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		velocity.x = input_direction * WALK_SPEED
		if is_on_floor():
			direction_facing = Vector2(input_direction, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
	
	if move_and_slide():
		push_bubbles()


func push_bubbles():
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody2D:
			collider.apply_force(direction_facing * PUSH_FORCE)


func blow_bubble():
	bubble_blown.emit(position, direction_facing)


func jump():
	if is_on_floor():
		velocity.y = -JUMP_SPEED


func update_animation_parameters() -> void:
	animation_tree.set("parameters/conditions/is_idle", 
		is_on_floor() and velocity == Vector2.ZERO)
	
	animation_tree.set("parameters/conditions/is_in_air",
		not is_on_floor())
	
	animation_tree.set("parameters/conditions/is_running",
		is_on_floor() and velocity.x != 0)
	
	animation_tree.set("parameters/conditions/is_blowing", 
		Input.is_action_just_pressed("blow"))
	
	animation_tree.set("parameters/conditions/is_jumping",
		Input.is_action_just_pressed("jump"))
	
	animation_tree.set("parameters/in air/blend_position",
		abs(velocity.y))


func _on_bubble_pop_hitbox_body_entered(body):
	bubble_popped.emit(body)


func _on_bubble_bounce_hitbox_body_entered(body):
	if Input.is_action_pressed("jump") and velocity.y > 0:
		jump()
	else:
		bubble_popped.emit(body)

