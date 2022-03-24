extends Node
class_name StateMachine

var state = null setget set_state
var previous_state = null
var states = {}

onready var parent = get_parent()

func _physics_process(delta):
	if state != null:
		state_logic(delta)
		var transiton = get_transiton(delta)
		if transiton != null:
			set_state(transiton)

func state_logic(_delta):
	pass

func get_transiton(delta):
	return null

func enter_state(new_state, old_state):
	pass

func exit_state(old_state, new_state):
	pass
	
func set_state(new_state):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		exit_state(previous_state, new_state)
	
	if new_state != null:
		enter_state(new_state, previous_state)
	 
func add_state(state_name):
	states[state_name] = states.size()
