@tool

extends Control

@export var _PLAYER_HEALTH : Node
@export var _PLAYER_LIVES : Node
@export var _SCORE : Node

@onready var _HEART_TEXTURE_WIDTH : int = $Health.texture.get_width()
@onready var _HEART_TEXTURE_HEIGHT : int = $Health.texture.get_height()

func _ready():
	_PLAYER_HEALTH.size.y = _HEART_TEXTURE_HEIGHT

func set_health(health : int) -> void:
	_PLAYER_HEALTH.size.x = _HEART_TEXTURE_WIDTH * health

func set_lives(lives : int) -> void:
	_PLAYER_LIVES.text = str(lives)

func set_score(score : int) -> void:
	_SCORE.text = "%d" % score

func _on_player_health_updated(new_health):
	set_health(new_health)

func _on_player_lives_updated(lives_remaining):
	set_lives(lives_remaining)

func _on_main_score_updated(new_score):
	set_score(new_score)
