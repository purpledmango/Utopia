extends Area2D
 
signal chest_empty
export var shards = 4
var c_button = preload("res://scenes/ui/buttons/C_button.tscn")
onready var anchor = $Position2D
var c_button_instance = c_button.instance()
var shard = preload("res://scenes/props/shard/shard.tscn")
onready var animationPlayer = $AnimationPlayer


var opened = false
var  can_open = false
# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer.play("closed")

func _process(delta):
	if Input.is_action_pressed("toggle") and can_open == true:
		shard_spawnner()
		

func shard_spawnner():
	animationPlayer.play("chest_open")
	var shard_instance = shard.instance()
	yield(get_tree().create_timer(0.5), "timeout")
	if shards > 0 and opened == false:
		add_child(shard_instance)
		shard_instance.position.x = anchor.position.x * rand_range(-1,1) + rand_range(-10,30)
		shards = shards - 1
	else:
		can_open = false
		opened = true
		emit_signal("chest_empty")
	



func _on_Chest_One_body_entered(body):
	if body.name == "Player" and opened == false:
		can_open  = true
		add_child(c_button_instance)
		c_button_instance.position = anchor.position


func _on_Chest_One_body_exited(body):
	if body.name == "Player" and opened == false:
		can_open = false
		remove_child(c_button_instance)
		
func _on_Chest_One_chest_empty():
	if get_children().has(c_button_instance):
		remove_child(c_button_instance)
	else:
		return
