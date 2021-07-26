extends Node

onready var parent = get_parent() 

onready var player = parent.get_parent()
onready var particle = get_node("Particle2D")
onready var sprite = player.get_node("sprite")
onready var wall_slide = parent.get_node("wall_slide")

onready var trail = load("res://src/Atlas/trail.tres")
onready var trail_flip = load("res://src/Atlas/trail_flip.tres")

export var Maxspeed = 500
export var Acceleration = 200

onready var init_var = {
	MAXSPEED = parent.Maxspeed,
	ACCELERATION = parent.Acceleration
}

var dir = 6

# warning-ignore:unused_signal
signal anim_state

var timers = {
	dash = null,
	dash_jump = null
}

var dash_timeout = false
var dash_jumped = false

func _ready():
	particle.emitting = false
	

# warning-ignore:unused_argument
func _physics_process(_delta):
	dash()
	dash_particle()

func dash():
	if timers.dash != null:
		dash_update()
	if timers.dash_jump != null:
		dash_jump()

	if player.is_on_floor() and Input.is_action_just_pressed("game_dash") and !Input.is_action_just_pressed("game_jump"):
		timers.dash = get_tree().create_timer(0.3)
		timers.dash.connect("timeout", self ,"_dash_timeout")
		particle.emitting = true
	elif player.is_on_floor() and Input.is_action_just_pressed("game_dash") and Input.is_action_just_pressed("game_jump"):
		timers.dash_jump = get_tree().create_timer(0.2)
		dash_jumped = true
		particle.emitting = true
		
	if is_wall_grab() and Input.is_action_just_pressed("game_dash"):
		timers.dash_jump = get_tree().create_timer(0.2)
		dash_jumped = true
		particle.emitting = true

		
	
func dash_update():
	if timers.dash.time_left > 0:
		parent.Maxspeed = Maxspeed
		parent.Acceleration = Acceleration
		if !Input.is_action_just_pressed("left") and !Input.is_action_just_pressed("right"):
			if sprite.flip_h:
				parent.simulate_left = true
			if !sprite.flip_h:
				parent.simulate_right = true
	if !Input.is_action_pressed("game_dash"):
		timers.dash.time_left = 0
	if Input.is_action_just_pressed("game_jump"):
		timers.dash_jump = get_tree().create_timer(0.2)
		dash_jumped = true

func _dash_timeout():
	parent.simulate_left = false
	parent.simulate_right = false
	if !dash_jumped:
		reset()
		
func dash_jump():
	parent.Maxspeed = 400
	if timers.dash_jump.time_left < 0.1:
		if player.is_on_floor() or is_wall_grab():
			reset()

func reset():
	parent.Maxspeed = init_var.MAXSPEED
	parent.Acceleration = init_var.ACCELERATION
	parent.JumpMax = init_var.MAXSPEED
	parent.simulate_left = false
	parent.simulate_right = false
	particle.emitting = false
	timers.dash = null
	timers.dash_jump = null
	dash_jumped = false

func is_wall_grab():
	if wall_slide.slide_command(4) or wall_slide.slide_command(6):
		return true
	else:
		return false

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
