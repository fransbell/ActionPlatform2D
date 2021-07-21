extends Control

#parent verifier
var scriptProcess = false

#preload script
onready var utility = preload("res://Entity/Utility/utility.gd")
onready var room = preload("res://Entity/Utility/room.gd")

#get world data
onready var tilemap = get_node("../")
onready var player = get_node("../../player")
onready var camera = get_node("../../Camera2D")

#init variable
var tilemap_cell = null
var room_bound = null
var _timer = null

#room identifier
var is_player_inRoom = false
var time_updating = false

func _ready():	
	tilemap_cell = tilemap.get_used_cells()
	room_bound = room.get_tilemapRect(tilemap_cell,tilemap.position,tilemap.cell_size,tilemap.scale)
	
func _physics_process(_delta):
	if !checkNode():
		return
	room.get_is_inRoom(player.position,room_bound,is_player_inRoom,camera)
	room_signal(player.position,room_bound)
	timer_update()

func checkNode():
	if get_parent() is TileMap:
		scriptProcess = true
		return scriptProcess
	printerr("Parent node is not TileMap, disable CameraController script.")
	pass

func room_signal(player_pos,bound):
	var tmp = {
		"top":bound[0].y,
		"left":bound[0].x,
		"bottom":bound[1].y,
		"right":bound[1].x
	}
	if is_player_inRoom:
		if player_pos.x < tmp.left or player_pos.x > tmp.right or player_pos.y < tmp.top or player_pos.y > tmp.bottom:
			is_player_inRoom = false
			room_exit()
			
	if !is_player_inRoom:
		if player_pos.x > tmp.left and player_pos.x < tmp.right and player_pos.y > tmp.top and player_pos.y < tmp.bottom:
			is_player_inRoom = true
			room_enter()

func room_enter():
	start_timer(0.4)
	pass
	
func room_exit():
	pass

func start_timer(time):
	_timer = get_tree().create_timer(time)
	time_updating = true
	utility.set_pause_node(player.get_node("ActionPlatform2D"),true)
	_timer.connect("timeout", self, "_on_timeout")
	
func timer_update():
	if time_updating:
		var velocity = player.bh2D.velocity
		var tmp = 60
		if velocity.x > 0 :
			player.move_and_slide(Vector2(tmp,0))
		elif velocity.x < 0:
			player.move_and_slide(Vector2(-tmp,0))
		elif velocity.y > 0 :
			player.move_and_slide(Vector2(0,tmp))
		elif velocity.y < 0:
			player.move_and_slide(Vector2(0,-(tmp+60)))

func _on_timeout():
	time_updating = false
	utility.set_pause_node(player.get_node("ActionPlatform2D"),false)
	print("entered %s" % [tilemap.name])

