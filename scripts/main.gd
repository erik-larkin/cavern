extends Node2D

const CHAIN_REACTION_POP_TIME : float = 0.03

signal score_updated(new_score : int)

var BUBBLE_SCENE = preload("res://scenes/Bubble.tscn")
var SCORE_POPUP_SCENE = preload("res://scenes/ScorePopup.tscn")
@onready var player = $Player
@onready var level = $Level 
@onready var camera = $Camera
var score = 0;

enum ItemTypes {APPLE, HEART, LEMON, LIFE, RASPBERRY}

# Called when the node enters the scene tree for the first time.
func _ready():
	player.spawn(level.get_player_spawn_point(), level.get_player_spawn_direction().x)
	$UI.set_health(player._maximum_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	move_bubbles_with_airflow()


func move_bubbles_with_airflow() -> void:
	var bubbles = $Bubbles.get_children()
	
	for bubble in bubbles:
		if bubble._is_floating:
			set_bubble_airflow_direction(bubble)


func get_airflow_direction_at_coords(coords : Vector2) -> Vector2:
	var level : Level = $Level
	return level.get_airflow_at_coords(coords)


func _on_player_bubble_blown(spawn_position : Vector2, direction : Vector2):
	var bubble_instance = BUBBLE_SCENE.instantiate()
	bubble_instance.init(spawn_position, direction)
	bubble_instance.popped_by_player.connect(_on_bubble_popped_by_player)
	bubble_instance.started_floating.connect(set_bubble_airflow_direction)
	$Bubbles.add_child(bubble_instance)


func set_bubble_airflow_direction(bubble : RigidBody2D):
	bubble.set_airflow_direction(get_airflow_direction_at_coords(bubble.position))


func _on_bubble_popped_by_player(bubble):
	if not player.dead():
		var popped : Array[RigidBody2D] = []
		recursive_bubble_pop(bubble, popped)


# DFS algorithm to pop all adjacent bubbles
func recursive_bubble_pop(bubble : RigidBody2D, popped : Array[RigidBody2D]):
	if bubble in popped:
		return
	
	var bubbles_to_pop = bubble.get_adjacent_bubbles()
	bubble.pop_and_defeat_enemy()
	popped.append(bubble)
	add_to_score(10 * popped.size(), bubble.position)
	
	get_tree().create_timer(CHAIN_REACTION_POP_TIME).timeout.connect(func():
		for adjacent_bubble in bubbles_to_pop:
			if adjacent_bubble != null and adjacent_bubble.has_method("pop"):
				recursive_bubble_pop(adjacent_bubble, popped)
	)


func shake_camera(strength : float) -> void:
	camera.apply_shake(strength)


func _on_level_item_collected(type):
	match (type):
		ItemTypes.HEART:
			if not $Player.gain_health(1):
				add_to_score(2000, player.position)
		ItemTypes.LEMON:
			add_to_score(100, player.position)
		ItemTypes.LIFE:
			$Player.gain_lives(1)
		ItemTypes.RASPBERRY:
			add_to_score(500, player.position)
		ItemTypes.APPLE, _:
			add_to_score(2000, player.position)


func _on_player_died(lives_remaining):
	if (lives_remaining > 0):
		get_tree().create_timer(1).timeout.connect(func():
			player.respawn(level.get_player_spawn_point(), level.get_player_spawn_direction().x)
		)


func _on_player_hurt(damage_ratio : float):
	shake_camera(3.0 * damage_ratio)


func _on_level_explosion():
	shake_camera(3.0)


func add_to_score(score_to_add : int, text_spawn_position : Vector2) -> void:
	update_score(score + score_to_add)
	spawn_score_text(score_to_add, text_spawn_position)


func update_score(new_score : int) -> void:
	score = new_score
	score_updated.emit(score)


func spawn_score_text(score : int, spawn_position : Vector2) -> void:
	var score_popup := SCORE_POPUP_SCENE.instantiate()
	score_popup.init(score, spawn_position)
	$UI.add_child(score_popup)
