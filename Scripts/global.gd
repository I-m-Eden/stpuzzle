extends Node

var current_scene = null

func _quit():
	get_tree().quit()
	pass

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
func goto_scene(_path):
	print(_path)
	call_deferred("_deferred_goto_scene", _path)
func _deferred_goto_scene(_path):
	current_scene.free()
	var s = ResourceLoader.load(_path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	
# 用户的通关记录
var map_info = []
var last_map = "map0"

# 关卡的存档文件格式 save_data, read_data
var grid_size = Vector2() # x=height, y=width
var grid = [] 
var mvgrid = []
var door = []
var pos = Vector2()
var region = []
var path = []

# UI 设计相关的变量
var viewrect = Rect2(0,0,800,600)

const SAVE_DIR = "res://save/"

func read_userdata():
	var file: File = File.new()
	var userdata_path = SAVE_DIR + "userdata.txt";
	if file.file_exists(userdata_path):
		var error = file.open_encrypted_with_pass(userdata_path, File.READ, "AAaa11@@")
		if error == OK:
			var data = file.get_var()
			map_info=data[0]
			last_map=data[1]
			file.close()
			return true
	return false
func save_userdata():
	var userdata_path = SAVE_DIR + "userdata.txt"
	var data=[]
	data.append(map_info)
	data.append(last_map)
	var directory: Directory = Directory.new()
	if !directory.dir_exists(SAVE_DIR):
		directory.make_dir_recursive(SAVE_DIR)
	var file: File = File.new()
	var error = file.open_encrypted_with_pass(userdata_path, File.WRITE, "AAaa11@@")
	if error == OK:
		file.store_var(data)
		file.close()
	pass


func read_mapdata(var filename):
	var file: File = File.new()
	var mapdata_path = SAVE_DIR + "mapdata_" + filename
	if file.file_exists(mapdata_path):
		var error = file.open_encrypted_with_pass(mapdata_path, File.READ, "AAaa11@@")
		if error == OK:
			var data = file.get_var()
			grid_size=data[0]
			grid=data[1]
			mvgrid=data[2]
			door=data[3]
			pos=data[4]
			region=data[5]
			path=[]
			file.close()
	pass

func save_mapdata(var filename):
	var mapdata_path = SAVE_DIR + "mapdata_" + filename
	var data=[]
	data.append(grid_size)
	data.append(grid)
	data.append(mvgrid)
	data.append(door)
	data.append(pos)
	data.append(region)
	var directory: Directory = Directory.new()
	if !directory.dir_exists(SAVE_DIR):
		directory.make_dir_recursive(SAVE_DIR)
	var file: File = File.new()
	var error = file.open_encrypted_with_pass(mapdata_path, File.WRITE, "AAaa11@@")
	if error == OK:
		file.store_var(data)
		file.close()
	pass

func check_valid(var data):
	if(len(data)!=7):
		return false
	return true
func read_data(var filename):
	var savedata_path =  SAVE_DIR + "savedata_" + filename
	var data_ok=false
	var file: File = File.new()
	if file.file_exists(savedata_path):
		var error = file.open_encrypted_with_pass(savedata_path, File.READ, "AAaa11@@")
		if error == OK:
			var data = file.get_var()
			if check_valid(data):
				grid_size=data[0]
				grid=data[1]
				mvgrid=data[2]
				door=data[3]
				pos=data[4]
				region=data[5]
				path=data[6]
				data_ok=true
			else:
				print('data invalid')
			file.close()
		else:
			print('file not found or file error')
	return data_ok

func save_data(var filename):
	var savedata_path =  SAVE_DIR + "savedata_" + filename
	var data=[]
	data.append(grid_size)
	data.append(grid)
	data.append(mvgrid)
	data.append(door)
	data.append(pos)
	data.append(region)
	data.append(path)
	var directory: Directory = Directory.new()
	if !directory.dir_exists(SAVE_DIR):
		directory.make_dir_recursive(SAVE_DIR)
	var file: File = File.new()
	var error = file.open_encrypted_with_pass(savedata_path, File.WRITE, "AAaa11@@")
	if error == OK:
		file.store_var(data)
		file.close()
	pass
