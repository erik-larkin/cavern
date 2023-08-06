extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction_facing = Vector2.LEFT


func _ready():
	change_direction()


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = direction_facing.x * SPEED

	move_and_slide()


func change_direction():
	direction_facing *= -1
	get_tree().create_timer(randf_range(1, 5)).timeout.connect(change_direction)
