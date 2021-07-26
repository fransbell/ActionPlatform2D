extends Node

onready var parent = get_parent() 
onready var player = parent.get_parent()
onready var lemon = load("res://Entity/Bullet/lemon.tscn")
onready var world = player.get_node("../")
onready var projectile = player.get_node("projectile")
onready var sprite = player.get_node("sprite")

var timers = {
	delay = null
}

func _ready():
	timers.delay = get_tree().create_timer(0)
	print(timers.delay.time_left)
	
func _physics_process(_delta):
	add_lemon()

func add_lemon():
	if timers.delay.time_left < 0.1 and Input.is_action_just_pressed("game_action"):
		timers.delay = get_tree().create_timer(0.3)
		var tmp = lemon.instance()
		tmp.position = player.position
		tmp.flip = true if sprite.flip_h else false
		projectile.add_child(tmp)
