extends Area2D
signal lift_toggled

var player_on_lift = false
onready var c_button = preload("res://scenes/ui/buttons/C_button.tscn")
onready var button_instance = c_button.instance()


# Called when the node enters the scene tree for the first time.
func _ready():
	var button_instance = c_button.instance()
	get_parent().add_child(button_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("toggle") and player_on_lift != false:
		remove_child(button_instance)
		emit_signal("lift_toggled")
		player_on_lift = false

func show_and_toggle():
	add_child(button_instance)
	button_instance.position = $Position2D.position
	

func _on_lift_body_entered(body):
	if body.name == "Player":
		player_on_lift = true
		show_and_toggle()


func _on_lift_body_exited(body):
	if body.name == "Player":
#		player_on_lift = false
		if button_instance:
			remove_child(button_instance)
		else:
			return

