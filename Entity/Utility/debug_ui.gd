extends Node

onready	var camera = get_node("../Camera2D")
onready	var input = get_node("Guage")
onready	var input2 = get_node("Guage2")
onready var timer_input = get_node("../player/ActionPlatform2D/jump_input_buffer")
onready var forgive = get_node("../player/ActionPlatform2D/jump_forgive")



func _ready():
	self.visible = true
	pass
	
func _physics_process(_delta):
	var tmp = camera.get_camera_screen_center()
	self.position = tmp - Vector2(300,150)
	
	var time_left = timer_input.time_left * 500
	var time_forgive = forgive.time_left *500
	
	input.rect_size.x = time_left
	input2.rect_size.x = time_forgive
	

