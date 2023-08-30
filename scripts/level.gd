extends Node2D

class_name Level

const _INVISIBLE_COLOUR : Color = Color(1, 1, 1, 0)
const _TRANSPARENT_COLOUR : Color = Color(1, 1, 1, 0.3)
const _EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")

enum Layers {Foreground, Airflow}

@export var _SHOW_AIRFLOWS : bool = false
@onready var _tile_map : TileMap = $TileMap


func _ready():
	var tile_map_colour = _INVISIBLE_COLOUR
	
	if _SHOW_AIRFLOWS:
		tile_map_colour = _TRANSPARENT_COLOUR
		
	_tile_map.set_layer_modulate(Layers.Airflow, tile_map_colour)
	
	for enemy in $Enemies.get_children():
		enemy.exploded.connect(_on_enemy_exploded);

func get_airflow_at_coords(coordinates : Vector2) -> Vector2i:
	var map_coordinates := _tile_map.local_to_map(_tile_map.to_local(coordinates))
	var tile_data := _tile_map.get_cell_tile_data(1, map_coordinates)
	
	if tile_data:
		return tile_data.get_custom_data("Direction")
	
	return Vector2.ZERO


func _on_enemy_exploded(enemy_position : Vector2):
	var explosion_instance = _EXPLOSION_SCENE.instantiate()
	explosion_instance.position = enemy_position
	add_child(explosion_instance)
