extends CharacterBody2D

signal bubble_blown

@export var WALK_SPEED = 300.0
@export var JUMP_SPEED = 500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction_facing = Vector2.LEFT
var state = State.IDLE
var blowing_bubble = false

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
	
	move_and_slide()


func blow_bubble():
	blowing_bubble = true
	$BubbleBlowTimer.start()
	bubble_blown.emit(position, direction_facing)


func set_state() -> State:
	if blowing_bubble:
		return State.BLOW
	elif not is_on_floor():
		return State.JUMP
	elif velocity.x != 0:
		return State.RUN
	else:
		return State.IDLE


func update_animation(state : State):
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
	velocity.y = -JUMP_SPEED


func _on_bubble_blow_timer_timeout():
	blowing_bubble = false


func _on_bubble_pop_hitbox_body_entered(body):
	body.pop()


func _on_bubble_bounce_hitbox_body_entered(body):
	if Input.is_action_pressed("jump") and velocity.y > 0:
		jump()
	else:
		body.pop()
