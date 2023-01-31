extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.

var _offset=Vector2()

func _ready():
	pass # Replace with function body.

func open_door(var p):
	gb.grid[p.x][p.y]=0
	set_cell(p.y+_offset.y,p.x+_offset.x,0)
	pass
func close_door(var p):
	gb.grid[p.x][p.y]=4
	set_cell(p.y+_offset.y,p.x+_offset.x,4)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
