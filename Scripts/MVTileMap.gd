extends TileMap

var _offset=Vector2()

func _ready():
	pass # Replace with function body.

# global 变量
#   gb.mvgrid, gb.pos 在这里变化

func sprite_move(npos):
	var pos=gb.pos
	set_cell(pos.y+_offset.y,pos.x+_offset.x,-1)
	set_cell(npos.y+_offset.y,npos.x+_offset.x,0)
	gb.mvgrid[pos.x][pos.y]=-1
	gb.mvgrid[npos.x][npos.y]=0
	gb.pos=npos
	pass
