extends Node

onready var Ray_R = get_node("../Ray_Right")
onready var Ray_L = get_node("../Ray_Left")
onready var player = get_node("../../player")
onready var particle = get_node("Particles2D") 
onready var sprite = get_node("../sprite")

var trail = load("res://src/Atlas/trail.tres")
var trail_flip = load("res://src/Atlas/trail_flip.tres")

var is_kick = false
var timer = null
var direction = 6

var velocity = Vector2.ZERO

signal anim_state

var timers = {
	kick = null,
	dash = null
	}
	
var dash_timeout = true
var dash_followup = false

func _physics_process(_delta):
	check_dir()
	wall_jump()
	dash()

# -------- Wall Jump --------
func wall_jump(): # Mechanic Container
	wall_slide()
	wall_kick()
	if timers.kick != null:
		_wall_kick_update()
	
func wall_slide(): # Wall slide Property
	if !player.is_on_floor():
		if player.bh2D.velocity.y > 0:
			if slide_command(4) or slide_command(6):
				emit_signal("anim_state", "Sliding")
				player.bh2D.JumpMin = 50
			else:
				player.bh2D.JumpMin = 500

# Wall kick mechanic 
func wall_kick(): 
	if Input.is_action_just_pressed("game_jump"):
		if player.bh2D.velocity.y > 0 and !player.is_on_floor():
			if slide_command(6):
				wall_kicked("right")
			if slide_command(4):
				wall_kicked("left")

func wall_kicked(dir):
	timers.kick = get_tree().create_timer(0.2)
	timers.kick.connect("timeout", self ,"_wall_kick_timeout")
	
	var peak = 600
	var gravity = 800
	var reversal = 800
	
	if dir == "right":
		player.bh2D.velocity += Vector2(-reversal,-peak)
		player.bh2D.JumpMax = peak
		player.bh2D.JumpMin = gravity
		player.bh2D.Maxspeed = reversal

	if dir == "left":
		player.bh2D.velocity += Vector2(reversal,-peak)
		player.bh2D.JumpMax = peak
		player.bh2D.JumpMin = gravity
		player.bh2D.Maxspeed = reversal

func _wall_kick_update():
	if timers.kick.time_left > 0:
		if timers.kick.time_left < 0.18:
			player.bh2D.Maxspeed = 360
		if Input.is_action_pressed("right"):
			sprite.flip_h = false
		if Input.is_action_pressed("left"):
			sprite.flip_h = true
	
func _wall_kick_timeout():
	player.bh2D.JumpMax = 360
	player.bh2D.JumpMin = 500
	print("kick timeout")

# -------- END --------

# -------- Dash --------

func dash():
	dash_Input()
	if timers.dash != null:
		_dash_update()
	dash_particle()
	dash_followup()

func dash_Input():
	if Input.is_action_just_pressed("game_dash") and player.is_on_floor():
		dash_timeout = false
		timers.dash = get_tree().create_timer(0.25)
		timers.dash.connect("timeout", self ,"_dash_timeout")

func dash_start():
	pass

func _dash_update():
	if timers.dash.time_left > 0 :
		if Input.is_action_pressed("game_dash") and player.is_on_floor():
			
			var Maxspeed = 700
			var Acceleration = 200
			
			player.bh2D.Maxspeed = Maxspeed
			player.bh2D.Acceleration = Acceleration
			
			print(player.bh2D.Maxspeed)
			
			if !Input.is_action_just_pressed("left") and !Input.is_action_just_pressed("right"):
				if check_dir() == 6:
					player.bh2D.velocity.x += 1200
				elif check_dir() == 4:
					player.bh2D.velocity.x -= 1200
				
			particle.emitting = true
			print("active")
		elif Input.is_action_just_released("game_dash"):
			timers.dash.time_left = 0 #force stop when released
			print("deactivate")

func dash_particle():
	particle.position = player.position
	if sprite.flip_h:
		particle.texture = trail_flip
	else:
		particle.texture = trail
	particle.texture.region = Rect2(
		(sprite.frame_coords.x*46),
		(sprite.frame_coords.y*51),
		46,51)

func _dash_timeout():
	dash_timeout = true
#	if player.is_on_floor():
#		player.bh2D.Maxspeed = 360
#		player.bh2D.Acceleration = 70
#		timers.dash = null
#		particle.emitting = false
	print("timeout")

func dash_followup():
	if dash_timeout and player.is_on_floor() or dash_timeout and (slide_command(4) or slide_command(6)):
		player.bh2D.Maxspeed = 360
		player.bh2D.Acceleration = 70
		timers.dash = null
		particle.emitting = false
		

# -------- END --------

#---- Utility Function -----

func check_dir():
	if Input.is_action_just_pressed("right"):
		direction = 6
	if Input.is_action_just_pressed("left"):
		direction = 4
	return direction

func slide_command(dir):
	#var input_tmp = Input.is_action_pressed("right") or Input.is_action_pressed("left")
	if dir == 4:
		if Ray_L.get_collider() != null and Input.is_action_pressed("left"):
			sprite.flip_h = true
			return true
	if dir == 6:
		if Ray_R.get_collider() != null and Input.is_action_pressed("right"):
			sprite.flip_h = false
			return true
	return false

# -------- END --------
