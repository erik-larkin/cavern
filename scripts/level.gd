extends Node2D

const _AIRFLOW_STRENGTH = 100

func _process(delta):
	affect_bubbles_in_airflow($AirFlow/LeftFlow, Vector2.LEFT)
	affect_bubbles_in_airflow($AirFlow/UpFlow, Vector2.UP)
	affect_bubbles_in_airflow($AirFlow/RightFlow, Vector2.RIGHT)
	affect_bubbles_in_airflow($AirFlow/DownFlow, Vector2.DOWN)


func affect_bubbles_in_airflow(airflow : Area2D, direction : Vector2) -> void:
	var bubbles = airflow.get_overlapping_bodies()
	for bubble in bubbles:
		if bubble.has_method("follow_airflow"):
			bubble.follow_airflow(direction * _AIRFLOW_STRENGTH)
