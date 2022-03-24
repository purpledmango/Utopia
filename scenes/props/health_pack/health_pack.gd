extends Area2D

signal update_new_health(new_amount)
onready var animationPlayer = $AnimationPlayer

var health_pack_amount = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer.play("flash")

func _on_health_pack_body_entered(body):
	if body.name == "Player":
		animationPlayer.play("absorb")
		emit_signal("update_new_health", health_pack_amount)
		yield(animationPlayer, "animation_finished")
		queue_free()
		


