extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var map_name=String()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	gb.goto_scene("res://Scenes/"+map_name+".tscn")
	pass # Replace with function body.
