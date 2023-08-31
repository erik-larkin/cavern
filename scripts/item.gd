extends Node2D

enum {APPLE, HEART, LEMON, LIFE, RASPBERRY}

# Called when the node enters the scene tree for the first time.
func _ready():
	var animation : String = "";
	match randi_range(APPLE, RASPBERRY):
		APPLE:
			animation = "apple"
		HEART:
			animation = "heart"
		LEMON:
			animation = "lemon"
		LIFE:
			animation = "life"
		RASPBERRY:
			animation = "raspberry"
	
	$AnimationPlayer.play(animation)
