extends Label

class_name ScorePopup

const DISAPPEAR_TIME := 1
const RISE_SPEED := 20

func init(score : int, spawn_position : Vector2):
	text = str(score)
	pivot_offset = size / 2
	position = spawn_position

func _ready():
	$DisappearTimer.wait_time = DISAPPEAR_TIME
	$DisappearTimer.start()

func _process(delta):
	position.y -= RISE_SPEED * delta
	modulate.a = $DisappearTimer.time_left / $DisappearTimer.wait_time 


func _on_disappear_timer_timeout():
	queue_free()
