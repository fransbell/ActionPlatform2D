extends KinematicBody2D

#preload ActionPlatform2D
onready var bh2D = get_node("ActionPlatform2D")
var state = null
#setting true by default incase of upgradable/disable functionality
#use bh2D.set_setting(prop,value)
func _ready():
	#initialize setting
	bh2D._setting = {
		WALK = true,
		JUMP = true,
		JUMP_VARIABLE = true,
		WALLSLIDE = true,
		WALLJUMP = true,
		GRAB = true
	}
	#bh2D.set_setting("JUMP",true) #set usage
	state = $AnimationTree.get("parameters/playback")
""""
# connect signal {anim_state} from ActionPlatform2D 
# signal anim_state return string
# need to setup AnimationPlayer/AnimationTree  state machine into following name
# Idle Walk Jumping Peak Falling Wallslide Walljump Grab
"""
func _on_anim_state(event):
	state.travel(event)
