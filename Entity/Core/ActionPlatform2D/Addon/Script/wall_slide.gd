extends Node

onready var parent = get_parent() 

onready var player = parent.get_parent()
onready var sprite = player.get_node("sprite")

onready var Ray_L = player.get_node("Ray_Left")
onready var Ray_R = player.get_node("Ray_Right")

signal anim_state

export var slide_speed = 200
export var kick_peak = 680
export var kick_reversal = 900
export var kick_gravity = 820

#startup variable before modification from ActionPlatform2D
onready var init_var = {
	JUMPMIN = parent.JumpMin,
	JUMPMAX = parent.JumpMax
}

var timers = {
	kick = null
}

func _physics_process(_delta):
	wall_jump()

# -------- Wall Jump --------
func wall_jump(): # Mechanic Container
	wall_slide()
	wall_kick()
	if timers.kick != null:
		_wall_kick_update()
	
func wall_slide(): # Wall slide Property
	if !player.is_on_floor():
		if parent.velocity.y > 0:
			if slide_command(4) or slide_command(6):
				emit_signal("anim_state", "Sliding")
				parent.JumpMin = slide_speed
			else:
				parent.JumpMin = init_var.JUMPMIN

# Wall kick mechanic 
func wall_kick(): 
	if Input.is_action_just_pressed("game_jump"):
		if parent.velocity.y > 0 and !player.is_on_floor():
			if slide_command(6):
				wall_kicked("right")
			if slide_command(4):
				wall_kicked("left")

func wall_kicked(dir):
	timers.kick = get_tree().create_timer(0.2)
	timers.kick.connect("timeout", self ,"_wall_kick_timeout")
		
	parent.JumpMax = kick_peak
	parent.JumpMin = kick_gravity
	parent.Maxspeed = kick_reversal
	
	if dir == "right":
		parent.velocity += Vector2(-kick_reversal,-kick_peak)
	if dir == "left":
		parent.velocity += Vector2(kick_reversal,-kick_peak)

func _wall_kick_update():
	if timers.kick.time_left > 0:
		if timers.kick.time_left < 0.18:
			parent.Maxspeed = init_var.JUMPMAX
		if Input.is_action_pressed("right"):
			sprite.flip_h = false
		if Input.is_action_pressed("left"):
			sprite.flip_h = true
	
func _wall_kick_timeout():
	parent.JumpMax = init_var.JUMPMAX
	parent.JumpMin = init_var.JUMPMIN

# -------- END --------

func slide_command(dir):
	if dir == 4:
		if Ray_L.get_collider() != null and Input.is_action_pressed("left"):
			sprite.flip_h = true
			return true
	if dir == 6:
		if Ray_R.get_collider() != null and Input.is_action_pressed("right"):
			sprite.flip_h = false
			return true
	return false
