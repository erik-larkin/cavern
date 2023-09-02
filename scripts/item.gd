@tool

extends Node2D

enum Types {APPLE, HEART, LEMON, LIFE, RASPBERRY}

@export var type : Types

var collected : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_animation()


func _process(_delta):
	if Engine.is_editor_hint():
		set_animation()


func set_animation() -> void:
	var animation : String = ""
	
	match (type): 
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
			
	$AnimationPlayer.play(animation)


func _on_hitbox_body_entered(body):
	if not collected:
		collected = true
		visible = false
		$CollectSound.play()
		$CollectSound.finished.connect(queue_free)


