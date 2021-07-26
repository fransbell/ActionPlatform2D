extends Sprite

var speed = 6
var flip = false


func _physics_process(_delta):
	var dir = -1 if flip else 1
	self.flip_h= true if dir == 1 else false
	dir = dir * speed
	self.position += Vector2(dir,0)
	
func _ready():
# warning-ignore:return_value_discarded
	get_node("notifier").connect("screen_exited", self, "_on_screen_exited")

func _on_screen_exited():
	queue_free()
