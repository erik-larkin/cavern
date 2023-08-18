extends Node

const DEFAULT_ENGINE_TIMESCALE =  1.0

func apply_hitstop(duration : float, time_scale : float):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = DEFAULT_ENGINE_TIMESCALE
