extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button1_pressed():
	get_node("..").process_next_map()
	pass # Replace with function body.


func _on_Button2_pressed():
	get_node("Win").visible=false
	pass # Replace with function body.


func _on_Back_pressed():
	gb.goto_scene('res://Scenes/main.tscn')
	pass # Replace with function body.
