@tool

class_name Item

extends Node2D

signal collected(type : Types)

enum Types {APPLE, HEART, LEMON, LIFE, RASPBERRY}

@export var _type : Types

# Called when the node enters the scene tree for the first time.
func _ready():
	set_animation()


func _process(_delta):
	if Engine.is_editor_hint():
		pass


func set_animation() -> void:
	var animation : String = ""
	
	match (_type): 
		Types.HEART:
			animation = "heart"
		Types.LEMON:
			animation = "lemon"
		Types.LIFE:
			animation = "life"
		Types.RASPBERRY:
			animation = "raspberry"
		Types.APPLE:
			animation = "apple"
	
	if (animation != $AnimationPlayer.current_animation):
		$AnimationPlayer.play(animation)


func _on_hitbox_body_entered(_body):
	if visible:
		visible = false
		collected.emit(_type)
		$CollectSound.play()
		$CollectSound.finished.connect(queue_free)


