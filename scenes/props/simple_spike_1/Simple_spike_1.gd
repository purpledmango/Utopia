extends Area2D

var damage = 55

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Simple_spike_1_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
