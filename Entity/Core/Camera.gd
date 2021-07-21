extends Camera2D

onready var transition = get_node("Tween")

func move_to(property,start,end,time):
	transition.interpolate_property(self,property,start,end,time,
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	transition.start()
