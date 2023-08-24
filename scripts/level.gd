extends Node2D

class_name Level

func get_airflow_at_coords(coordinates : Vector2) -> Vector2i:
	var tile_map : TileMap = $TileMap
	var map_coordinates := tile_map.local_to_map(tile_map.to_local(coordinates))
	var tile_data := tile_map.get_cell_tile_data(1, map_coordinates)
	
	if tile_data:
		return tile_data.get_custom_data("Direction")
	
	return Vector2.ZERO

