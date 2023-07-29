extends CharacterBody2D

signal bubble_blown

@export var WALK_SPEED = 300.0
@export var JUMP_SPEED = 500.0

var blowing_bubble = false

const LEFT = -1
const RIGHT = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction_facing = LEFT

enum State {BLOW, DIE, IDLE, JUMP, RUN}

func _process(_delta):
	if Input.is_action_just_pressed("blow") and not blowing_bubble:
		blow_bubble()

	var state = set_state()
	update_animation(state)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_SPEED
	
	# Get the input direction and handle the movement/deceleration.
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		velocity.x = input_direction * WALK_SPEED
		direction_facing = input_direction
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
	
	move_and_slide()


func blow_bubble():
	blowing_bubble = true
	$BubbleBlowTimer.start()
	bubble_blown.emit(position)


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
	if direction_facing == RIGHT:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	match state: 
		State.DIE:
			$AnimatedSprite2D.play("die")
		State.BLOW:
			$AnimatedSprite2D.play("blow")
		State.JUMP:
			$AnimatedSprite2D.play("jump")
		State.RUN:
			$AnimatedSprite2D.play("run")
		State.IDLE, _:
			$AnimatedSprite2D.play("idle")


func _on_bubble_blow_timer_timeout():
	blowing_bubble = false
