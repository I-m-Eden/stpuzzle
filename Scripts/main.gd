extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_Continue_pressed():
	if(!gb.read_userdata()):
		gb.map_info=[]
		gb.last_map="map0"
		gb.save_userdata()
	gb.goto_scene("res://Scenes/"+gb.last_map+".tscn")
	pass # Replace with function body.

func _on_Button_Exit_pressed():
	gb._quit()
	pass # Replace with function body.

func _on_Button_Choose_pressed():
	gb.goto_scene("res://Scenes/mapchoose.tscn")
	pass # Replace with function body.
