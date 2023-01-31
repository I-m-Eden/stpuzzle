extends Node

export var _hint_text=String()

export var _ending=[]
export var _name=String()
export var _offset=Vector2()

export var _size=Vector2()
export var _door=[]
export var _region=[]
export var _rect: PackedScene = null
var rect_list=[]
var total_collect=[]
var collect=[]
var door_rgid=[]
var region_id=[]
var total_gold_num=0
var gold_num=0

var _filename=""

func checkregion(pos,region):
	for j in range(len(region)):
		var rt=region[j]
		if(pos.x>=rt[0] and pos.x<=rt[1] and pos.y>=rt[2] and pos.y<=rt[3]):
			return true
	return false
var idea_pos=Vector2()
var idea_zoom=Vector2()

func _process(delta):
	var cam_pos=get_node("Camera2D").position
	var dis=(cam_pos-idea_pos).length()
	var speed=400
	if(dis>400):
		speed=400+(dis-400)
	else:
		speed=sqrt(1.0*dis/400)*400
	if(dis>0.1):
		var dv=(idea_pos-cam_pos).normalized()
		cam_pos+=min(dis,delta*speed)*dv
		get_node("Camera2D").position=cam_pos
	pass
	var cam_zoom=get_node("Camera2D").zoom
	dis=(cam_zoom-idea_zoom).length()
	if(dis>0.001):
		var dv=(idea_zoom-cam_zoom).normalized()
		cam_zoom+=min(dis,delta*0.2)*dv
		get_node("Camera2D").zoom=cam_zoom
		_camera_calculate()

func _camera_calculate(rg=null):
	if(rg==null):
		rg=gb.region[region_id[gb.pos.x][gb.pos.y]]
	var cell_size=get_node("STTileMap").cell_size
	var rgrect = [10000,0,10000,0]
	for j in range(len(rg)):
		rgrect[0]=min(rgrect[0],rg[j][0])
		rgrect[2]=min(rgrect[2],rg[j][2])
		rgrect[1]=max(rgrect[1],rg[j][1])
		rgrect[3]=max(rgrect[3],rg[j][3])
	if (rgrect[1]-rgrect[0]>15 or rgrect[3]-rgrect[2]>15):
		idea_zoom=Vector2(1,1)
	else:
		idea_zoom=Vector2(0.7,0.7)
	var tmpx=float(rgrect[2]+rgrect[3])/2
	var tmpy=float(rgrect[0]+rgrect[1])/2
	if(tmpx-gb.pos.y>3 and tmpx-rgrect[2]>5):tmpx-=float(tmpx-gb.pos.y-3)/(tmpx-rgrect[2]-3)*(tmpx-rgrect[2]-5)
	if(tmpy-gb.pos.x>3 and tmpy-rgrect[0]>5):tmpy-=float(tmpy-gb.pos.x-3)/(tmpy-rgrect[0]-3)*(tmpy-rgrect[0]-5)
	if(gb.pos.y-tmpx>3 and rgrect[3]-tmpx>5):tmpx+=float(gb.pos.y-tmpx-3)/(rgrect[3]-tmpx-3)*(rgrect[3]-tmpx-5)
	if(gb.pos.x-tmpy>3 and rgrect[1]-tmpy>5):tmpy+=float(gb.pos.x-tmpy-3)/(rgrect[1]-tmpy-3)*(rgrect[1]-tmpy-5)
	idea_pos.x=-gb.viewrect.size.x/2*get_node("Camera2D").zoom.x+(tmpx+0.5)*cell_size.x
	idea_pos.y=-gb.viewrect.size.y/2*get_node("Camera2D").zoom.y+(tmpy+0.5)*cell_size.y
	idea_pos+=Vector2(_offset.y*cell_size.x,_offset.x*cell_size.y)
	pass
	
func activate_map():
	var rid = region_id[gb.pos.x][gb.pos.y]
	var rg = gb.region[rid]
	var cell_size=get_node("STTileMap").cell_size
	var map_pos = get_node("STTileMap").position
	_camera_calculate(rg)
	_route_calculate()
	get_node("HUD/Collect").text=": "+str(collect[rid])+"/"+str(total_collect[rid])
	for i in range(len(gb.door)):
		var p=gb.door[i]
		if (door_rgid[i]==rid):
			var pp=map_pos+Vector2(_offset.y*cell_size.x,_offset.x*cell_size.y)
			if (p[1]<=collect[door_rgid[i]]):
				get_node("STTileMap").open_door(p[0])
				pp.x+=p[0].y*cell_size.x
				pp.y+=p[0].x*cell_size.y
				rect_list[i].color=Color(0,1,1,0.3)
				rect_list[i].rect2=Rect2(pp.x,pp.y,32,32)
				rect_list[i].update()
			else:
				get_node("STTileMap").close_door(p[0])
				var ph=float(collect[door_rgid[i]])/p[1]*cell_size.y
				pp.x+=p[0].y*cell_size.x
				pp.y+=(p[0].x+1)*cell_size.y-ph
				rect_list[i].color=Color(0.3,0.3,1,0.7)
				rect_list[i].rect2=Rect2(pp.x,pp.y,32,ph)
				rect_list[i].update()
	gb.save_data(_filename)
	pass

func process_next_map():
	gb.goto_scene("res://Scenes/"+_ending[1]+".tscn")
	pass

func process_win():
	get_node("HUD/Win").visible = true
	get_node("HUD/Win/GoldNum").text=": "+str(gold_num)+"/"+str(total_gold_num)
	var tag=false
	for i in range(len(gb.map_info)):
		if(gb.map_info[i][0]==_name):
			gb.map_info[i][1]=max(gb.map_info[i][1], gold_num)
			tag=true
			break
	if(tag==false):
		gb.map_info.append([_name,gold_num,total_gold_num])
	gb.save_userdata()
	pass
	
func process_back():
	if(len(gb.path)>1):
		gb.path.pop_back()
		var pos=gb.pos
		var npos=gb.path[len(gb.path)-1]
		get_node("MVTileMap").sprite_move(npos)
		if(gb.grid[pos.x][pos.y]!=7):
			get_node("PATHTileMap").paint_path(len(gb.path), pos)
		if(gb.grid[npos.x][npos.y]!=7):
			get_node("PATHTileMap").paint_path(len(gb.path)-1, npos)
		return true
	return false
	
# 用于判定在 pos 位置处的地图元素要求是否与路线矛盾
func judge_ok(id, posl,pos,posr):
	if posl==null: return true
	# 不能走回头路
	if((pos.x-posl.x)*(pos.x-posr.x)>0 or (pos.y-posl.y)*(pos.y-posr.y)>0):
		return false
	# 如果是空地、草地或门，那么一定合法
	if id==0 or id==6 or id==7: return true
	print(":::",posl,' ',pos,' ',posr)
	if id==1:
		if((abs(pos.x-posl.x)>0 and abs(pos.y-posr.y)>0) or (abs(pos.y-posl.y)>0 and abs(pos.x-posr.x)>0)):
			return true
	if id==2:
		if((abs(pos.x-posl.x)>0 and abs(pos.x-posr.x)>0) or (abs(pos.y-posl.y)>0 and abs(pos.y-posr.y)>0)):
			return true
	return false
func process_move(dx,dy):
	var pos=gb.pos
	var npos=Vector2(pos.x+dx,pos.y+dy)
	while (gb.grid[npos.x][npos.y]==5):
		npos.x+=dx
		npos.y+=dy
	var moveok = false
	if (get_node("PATHTileMap").get_cell(npos.y+_offset.y,npos.x+_offset.x)==-1 and gb.grid[npos.x][npos.y]!=3 and gb.grid[npos.x][npos.y]!=4):
		var lastpos=null
		if (len(gb.path)>1):
			lastpos=gb.path[len(gb.path)-2]
		if (judge_ok(gb.grid[pos.x][pos.y],lastpos,pos,npos)):
			gb.path.append(npos)
			get_node("MVTileMap").sprite_move(npos)
			if(gb.grid[pos.x][pos.y]!=7):
				get_node("PATHTileMap").paint_path(len(gb.path)-2, pos)
			if(gb.grid[npos.x][npos.y]!=7):
				get_node("PATHTileMap").paint_path(len(gb.path)-1, npos)
			moveok=true
	print(_ending[0])
	print(gb.pos)
	if (moveok and gb.pos==_ending[0]):
		process_win()
	return moveok

func _input(event):
	var changed=false
	var dx=0
	var dy=0
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_LEFT:
			dx = 0
			dy = -1
		if event.scancode == KEY_RIGHT:
			dx = 0
			dy = 1
		if event.scancode == KEY_UP:
			dx = -1
			dy = 0
		if event.scancode == KEY_DOWN:
			dx = 1
			dy = 0
		if event.scancode == KEY_BACKSPACE:
			changed = changed or process_back()
	if (dx!=0 or dy!=0):
		changed = changed or process_move(dx,dy)
	if (changed):
		activate_map()
	pass

func _anim_init():
	rect_list=[]
	var map_pos=get_node("STTileMap").position
	var cell_size=get_node("STTileMap").cell_size
	for i in range(len(gb.door)):
		var rt = _rect.instance()
		var p=gb.door[i][0]
		var pp=map_pos
		pp.x+=p.y*cell_size.x
		pp.y+=(p.x+1)*cell_size.y
		rt.rect2=Rect2(pp.x,pp.y,32,0)
		rt.color=Color(0.3,0.3,1,0.7)
		add_child(rt)
		rect_list.append(rt)
	pass
	
func _region_init():
	region_id=[]
	for i in range(gb.grid_size.x):
		region_id.append([])
		for j in range(gb.grid_size.y):
			region_id[i].append(null)
	for i in range(len(gb.region)):
		for j in range(len(gb.region[i])):
			for x in range(gb.region[i][j][0],gb.region[i][j][1]+1,1):
				for y in range(gb.region[i][j][2],gb.region[i][j][3]+1,1):
					if(region_id[x][y]==null):
						region_id[x][y]=i
	var fixed=true
	for i in range(gb.grid_size.x):
		for j in range(gb.grid_size.y):
			if(region_id[i][j]==null):
				fixed=false
	if(!fixed):
		for i in range(gb.grid_size.x):
			for j in range(gb.grid_size.y):
				if(region_id[i][j]==null):region_id[i][j]=len(gb.region)
		gb.region.append([[0,gb.grid_size.x-1,0,gb.grid_size.y-1]])
	door_rgid=[]
	for i in range(len(gb.door)):
		door_rgid.append(region_id[gb.door[i][0].x][gb.door[i][0].y])
	total_collect=[]
	for k in range(len(gb.region)):
		total_collect.append(0)
	for i in range(gb.grid_size.x):
		for j in range(gb.grid_size.y):
			if(gb.grid[i][j]==1 or gb.grid[i][j]==2):
				if(region_id[i][j]!=null):
					total_collect[region_id[i][j]]+=1
	pass
func _route_calculate():
	collect=[]
	for i in range(len(gb.region)):
		collect.append(0)
	gold_num=0
	for i in range(len(gb.path)):
		if(gb.grid[gb.path[i].x][gb.path[i].y]==1 or gb.grid[gb.path[i].x][gb.path[i].y]==2):
			collect[region_id[gb.path[i].x][gb.path[i].y]]+=1
		if(gb.grid[gb.path[i].x][gb.path[i].y]==6):
			gold_num+=1
	total_gold_num=0
	for j in range(gb.grid_size.x):
		for k in range(gb.grid_size.y):
			if(gb.grid[j][k]==6):
				total_gold_num+=1
	get_node("HUD/GoldNum").text=": "+str(gold_num)+"/"+str(total_gold_num)
	pass

func _ready():
	randomize()
	Engine.target_fps = 60
	idea_zoom=get_node("Camera2D").zoom
	idea_pos=get_node("Camera2D").position
	_filename=_name+'.txt'
	
	gb.last_map=_name
	gb.save_userdata()
	
	# 读取当前场景中的地图信息
	_read_grid()
	# 保存地图信息
	if (not gb.read_data(_filename)):
		gb.save_mapdata(_filename)
	_paint_all()
	
	#一些动画所需的实例初始化
	_anim_init()
	_region_init()
	_route_calculate()
	activate_map()
	get_node("HUD/Win").visible=false
	var tmp=_hint_text.split('·',true,-1)
	var fulltext=""
	for i in range(1,len(tmp),1):
		fulltext=fulltext+"· "+tmp[i]+'\n'+'\n'
	get_node("HUD/Region1/Label").text=fulltext

func _paint_all():
	var h=gb.grid_size.x
	var w=gb.grid_size.y
	var map
	map=get_node("STTileMap")
	for j in range(h):
		for k in range(w):
			map.set_cell(k+_offset.y,j+_offset.x,gb.grid[j][k])
	map=get_node("MVTileMap")
	for j in range(h):
		for k in range(w):
			map.set_cell(k+_offset.y,j+_offset.x,gb.mvgrid[j][k])
	map=get_node("PATHTileMap")
	for i in range(len(gb.path)):
		if (gb.grid[gb.path[i].x][gb.path[i].y]!=7):
			map.paint_path(i,gb.path[i])
	pass

func grid_init(height, width):
	for j in range(height):
		gb.grid.append([])
		for k in range(width):
			gb.grid[j].append(null)
	pass
func read_stmap(h,w):
	var map
	map= get_node("STTileMap")
	grid_init(h,w)
	for j in range(h):
		for k in range(w):	
			gb.grid[j][k] = map.get_cell(k+_offset.y,j+_offset.x)
func mvgrid_init(height, width):
	for j in range(height):
		gb.mvgrid.append([])
		for k in range(width):
			gb.mvgrid[j].append(null)
	pass
func read_mvmap(h, w):
	var mvmap
	mvmap= get_node("MVTileMap")
	mvgrid_init(h,w)
	for j in range(h):
		for k in range(w):
			gb.mvgrid[j][k] = mvmap.get_cell(k+_offset.y,j+_offset.x)
			if (gb.mvgrid[j][k]==0):
				gb.pos=Vector2(j,k)
	gb.path.append(gb.pos)
	pass

	
func _read_grid():
	gb.grid=[]
	gb.mvgrid=[]
	gb.path=[]
	gb.door=[]
	gb.grid_size = _size # x=height,y=width
	var h=gb.grid_size.x
	var w=gb.grid_size.y
	get_node("STTileMap")._offset=_offset
	get_node("MVTileMap")._offset=_offset
	get_node("PATHTileMap")._offset=_offset
	read_stmap(h,w)
	read_mvmap(h,w)
	for i in range(len(_door)):
		_door[i][0]-=_offset
	gb.door = _door
	for i in range(len(_region)):
		for j in range(len(_region[i])):
			_region[i][j][0]-=_offset.x
			_region[i][j][1]-=_offset.x
			_region[i][j][2]-=_offset.y
			_region[i][j][3]-=_offset.y
	gb.region = _region
	_ending[0]-=_offset


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
