extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var _mapchoose_button: PackedScene = null
# position: 80 120
var pos=Vector2(80,120)
var maplist=["map0","map1","map2","map3","map4"]
var buttonlist=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	buttonlist=[]
	for i in range(len(maplist)):
		var res = _mapchoose_button.instance()
		res.rect_position = pos + Vector2(0,res.rect_size.y) * i
		res.text=maplist[i]
		res.map_name=maplist[i]
		buttonlist.append(res)
		add_child(res)
	gb.read_userdata()
	print(gb.map_info)
	for i in range(len(gb.map_info)):
		for j in range(len(maplist)):
			if(gb.map_info[i][0]==maplist[j]):
				var tmptext=": "+str(gb.map_info[i][1])+"/"+str(gb.map_info[i][2])
				buttonlist[j].get_node("Info/GoldNum").text=tmptext
	pass # Replace with function body.


func _on_Button_Exit_pressed():
	gb.goto_scene("res://Scenes/main.tscn")
	pass # Replace with function body.

