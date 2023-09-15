extends Label

class_name ScorePopup

const DISAPPEAR_TIME := 1
const RISE_SPEED := 20

func init(score : int, spawn_position : Vector2):
	text = str(score)
	pivot_offset = size / 2
	position = spawn_position


func _ready():
	get_tree().create_timer(DISAPPEAR_TIME).timeout.connect(queue_free)


func _process(delta):
	position.y -= RISE_SPEED * delta
