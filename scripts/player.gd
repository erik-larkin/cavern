extends CharacterBody2D

signal bubble_blown(spawn_position, direction)
signal bubble_popped(bubble)

@export var WALK_SPEED = 300.0
@export var JUMP_SPEED = 500.0
@export var PUSH_FORCE = 300.0

const RUN_STEP_FRAMES = [1,3]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction_facing = Vector2.LEFT
var state = State.IDLE
var blowing_bubble = false
var on_ground = true

enum State {BLOW, DIE, IDLE, JUMP, RUN}

func _process(_delta):
	if Input.is_action_just_pressed("blow") and not blowing_bubble:
		blow_bubble()

	state = set_state()
	update_animation(state)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		on_ground = false
	else:
		if not on_ground:
			$SFX/Footsteps.play()
		on_ground = true

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	
	# Get the input direction and handle the movement/deceleration.
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		velocity.x = input_direction * WALK_SPEED
		direction_facing = Vector2(input_direction, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
	
	if move_and_slide():
		push_bubble()


func push_bubble():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			collider.apply_force(collision.get_normal() * -PUSH_FORCE)


func blow_bubble():
	blowing_bubble = true
	$SFX/Blow.play()
	$BubbleBlowTimer.start()
	bubble_blown.emit(position, direction_facing)


func set_state() -> State:
	if blowing_bubble:
		return State.BLOW
	elif not is_on_floor():
		return State.JUMP
	elif Input.get_axis("move_left", "move_right") != 0:
		return State.RUN
	else:
		return State.IDLE


func update_animation(state : State):
	# Only update direction if on the ground
	if is_on_floor():
		if direction_facing == Vector2.RIGHT:
			$AnimatedSprite.flip_h = true
			$BubblePopHitbox.scale.x = -1
		else:
			$AnimatedSprite.flip_h = false
			$BubblePopHitbox.scale.x = 1
	
	match state: 
		State.DIE:
			$AnimatedSprite.play("die")
		State.BLOW:
			$AnimatedSprite.play("blow")
		State.JUMP:
			$AnimatedSprite.play("jump")
		State.RUN:
			$AnimatedSprite.play("run")
		State.IDLE, _:
			$AnimatedSprite.play("idle")


func jump():
	$SFX/Jump.play()
	velocity.y = -JUMP_SPEED


func _on_bubble_blow_timer_timeout():
	blowing_bubble = false


func _on_bubble_pop_hitbox_body_entered(body):
	bubble_popped.emit(body)


func _on_bubble_bounce_hitbox_body_entered(body):
	if Input.is_action_pressed("jump") and velocity.y > 0:
		jump()
	else:
		bubble_popped.emit(body)


func _on_animated_sprite_frame_changed():
	if $AnimatedSprite.animation == "run":
		if $AnimatedSprite.frame in RUN_STEP_FRAMES:
			$SFX/Footsteps.play()
