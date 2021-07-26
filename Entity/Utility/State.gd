extends Resource

# state type using for easily handle state
class_name State

var state_container = []
var current_state = null
var previous_state = null
var is_debug_fired = false

func init(states:Array,start_state = null):
	if start_state == null:
		start_state = states[0]
	state_container = states
	current_state = start_state
	return

#add single state
func add_state(state:String):
	state_container.append(str(state))
	return

#add multiple state
func add_states(param:Array):
	for x in param:
		state_container.append(str(x))
	return

func set_state(state:String):
	#check if stated is changing
	if state == previous_state:
		return
	# if change continue
	# indentify is state exist in state_container
	if state_container.has(state):
		previous_state = current_state
		_exit_state()
		current_state = state
		_enter_state()
		is_debug_fired = false
		return
	else:
		if !is_debug_fired:
			printerr(">>> Invalid state name [%s] does not exist." % [state])
			is_debug_fired = true
		return
	
func _exit_state():
	pass

func _enter_state():
	pass

func get_states():
	return state_container
	
func get_state():
	return current_state

func get_previous_state():	return previous_state

func get_state_count():
	return state_container.count()
