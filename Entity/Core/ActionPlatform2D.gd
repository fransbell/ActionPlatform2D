extends Node

class_name ActionPlatform2D

#initialize script
export var Maxspeed = 360
export var Acceleration = 70
export var Gravity = 1200
export var JumpMax = 360
export var JumpMin = 500
export var JumpAccel = 50
export var JA_Modifier = 50 #jump acceleration modifier
export var AirModifier = 1

onready var player = get_parent()#get_node("../../player")

var Slide_modifier = 1

var velocity = Vector2.ZERO
var _dir = 0
var _timer
var is_falling = false #falling with out input
var is_jumped = null
var Dash = 0 

var core_overwrite = false
var scriptProcess = false

var dir_input_stack = ["blank"]
 
var _setting = {
	WALK = true,
	JUMP = true,
	JUMP_VARIABLE = true,
	WALLSLIDE = true,
	WALLJUMP = true,
	GRAB = true
}

signal anim_state

enum state {IDLE,WALK,JUMP,WALLSLIDE,WALLJUMP,GRAB}
#emit signal with emit_signal("anim_state", state)

#initialize timer
onready var timer_jump = get_node("jump")
onready var timer_jump_input = get_node("jump_input_buffer")
onready var timer_jump_forgive = get_node("jump_forgive")

func _ready():
	checkNode()
	timer_jump.connect("timeout", self, "timer_jump_timeout")
	timer_jump_input.connect("timeout", self, "timer_input_timeout")
	timer_jump_forgive.connect("timeout", self, "timer_forgive_timeout")
	

func _physics_process(delta):
	if !scriptProcess:
		return
	if !core_overwrite:
		update_velocity(delta)
	animated_sprite()
	input_buffer()

#---- Gameplay Function --- 

# check if parent is KinematucBody2D
func checkNode():
	if get_parent() is KinematicBody2D:
		scriptProcess = true
		return scriptProcess
	printerr("Parent node is not KinematicBody2D, disable PlaformBehavior2D script.")
	pass

# main movement
func update_velocity(delta):
		
	if Input.is_action_pressed("right"):
		velocity.x += Acceleration
		
	if Input.is_action_pressed("left"):
		velocity.x -= Acceleration
		
	if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		velocity.x = lerp(velocity.x,0,0.6)
	
	if player.is_on_floor():
		AirModifier = 1
		is_jumped = false
		is_falling = false
		if _setting.JUMP:
			if (timer_jump_input.time_left * 500) >= 50 :
				#.time_left * 333
				is_jumped = true
				jump_start()
	else:
		if _setting.JUMP:
			if (timer_jump_forgive.time_left * 500) >= 20 and (timer_jump_input.time_left * 500) >= 50:
				is_jumped = true
				jump_start()
				AirModifier = 2.5
		
	
	if !is_jumped and velocity.y > 0:
		if !is_falling:
			jump_forgive()
			is_falling = true

	timer_update()
	velocity.y += Gravity * delta * Slide_modifier
	
	velocity.y = clamp(velocity.y, -JumpMax,JumpMin)
	velocity.x = clamp(velocity.x, -Maxspeed,Maxspeed)
	velocity = velocity.round()
	
	velocity = player.move_and_slide(velocity, Vector2.UP)

func animated_sprite():
	
	if velocity.x > 0 or velocity.x < 0:
		emit_signal("anim_state", "Walk")
	else:
		if player.is_on_floor():
			emit_signal("anim_state", "Idle")
	
	if velocity.y < 0:
		emit_signal("anim_state", "Jump_Loop")
	elif velocity.y > 0:
		emit_signal("anim_state", "Falling")
	
	if velocity.x < 0:
		player.get_node("sprite").flip_h = true
	elif velocity.x > 0:
		player.get_node("sprite").flip_h = false

func input_buffer():
	if Input.is_action_just_pressed("game_jump"):
		jump_input()

func jump_start():
	timer_jump.start()

func jump_input():
	timer_jump_input.start()
	
func jump_forgive():
	timer_jump_forgive.start()

func timer_update():
	if !timer_jump.is_stopped():
		if Input.is_action_pressed("game_jump"):
			velocity.y -= JumpAccel - JA_Modifier
			JA_Modifier = JA_Modifier - 20
		if Input.is_action_just_released("game_jump"):
			JA_Modifier = JumpAccel

func timer_jump_timeout():
	pass
	#print("timeout")
func timer_input_timeout():
	pass
	#print("input timeout")
func timer_forgive_timeout():
	pass

#---- END --- 

#---- Setter / Getter --- 
func set_setting(prop,value):
	self._setting[str(prop)] = value
	return
