extends Node2D

var player_on_lift = false
onready var animationPlayer = $AnimationPlayer

var c_button = preload("res://scenes/ui/buttons/C_button.tscn")
onready var button_instance1 = c_button.instance()
onready var button_instance2 = c_button.instance()
var is_up = false
var is_down = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("toggle"):
		if is_up == true:
			remove_child(button_instance1)
			animationPlayer.play("lift_down")
	elif event.is_action_pressed("toggle"):
		if is_down == true:
			remove_child(button_instance2)
			animationPlayer.play("lift_up")
		


func _on_Upper_detect_area_body_entered(body):
	if body.name == "Player":
		add_child(button_instance1)
		button_instance1.position = $"Kinematic/Position2D".position
		is_up = true
		is_down = false
		

func _on_Upper_detect_area_body_exited(body):
	if body.name == "Player":
		is_up = false
		


func _on_Lower_detect_area_body_entered(body):
	if body.name == "Player":
		add_child(button_instance2)
		button_instance2.position = $"Kinematic/Position2D".position
		is_up = false
		is_down = true
		


func _on_Lower_detect_area_body_exited(body):
	if body.name == "Player":
		is_down = false



func _on_Player_c_pressed():
	if is_up == true:
			remove_child(button_instance1)
			animationPlayer.play("lift_down")
	elif is_down == true:
			remove_child(button_instance2)
			animationPlayer.play("lift_up")
		
