extends TileMap

var _offset=Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# 在执行 paint_path 前需要先修改 gb.path
# paint_path 通过读取 gb.path 来绘制路径

func paint_path(pn, pos):
	var posr
	var posl
	var id=-1
	if(pn==0 and pn<len(gb.path)-1):
		posr = gb.path[pn+1]
		if (posr.y<pos.y): id=0
		if (posr.y>pos.y): id=1
		if (posr.x<pos.x): id=2
		if (posr.x>pos.x): id=3
	else: if(pn>0 and pn==len(gb.path)-1):
		posl = gb.path[pn-1]
		if (posl.y<pos.y): id=0
		if (posl.y>pos.y): id=1
		if (posl.x<pos.x): id=2
		if (posl.x>pos.x): id=3
	else: if(pn>0 and pn<len(gb.path)-1):
		posl = gb.path[pn-1]
		posr = gb.path[pn+1]
		if (posl.y<pos.y and posr.y>pos.y or posl.y>pos.y and posr.y<pos.y):
			id=4
		if (posl.x<pos.x and posr.x>pos.x or posl.x>pos.x and posr.x<pos.x):
			id=5
		if (posl.y<pos.y and posr.x>pos.x or posl.x>pos.x and posr.y<pos.y):
			id=6
		if (posl.y<pos.y and posr.x<pos.x or posl.x<pos.x and posr.y<pos.y):
			id=7
		if (posl.y>pos.y and posr.x<pos.x or posl.x<pos.x and posr.y>pos.y):
			id=8
		if (posl.y>pos.y and posr.x>pos.x or posl.x>pos.x and posr.y>pos.y):
			id=9
	set_cell(pos.y+_offset.y,pos.x+_offset.x,id)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
