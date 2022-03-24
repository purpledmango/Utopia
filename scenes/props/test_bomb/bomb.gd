extends RigidBody2D

signal thow

onready var animationPlayer = $Sprite
var speed = Vector2(125, -55)
#var velocity = Vector2.ZERO
var damage = 50
var degree = 0
export var direction = -1


func set_self_direction(dir):	
	if dir > 0:
		thrown()
#		animationPlayer.flip_h = false 
		direction = 1
	elif dir < 0:
		thrown()
#		animationPlayer.flip_h = true
		direction = -1

#func _on_dummy_bullet_body_entered(body):
#	if body.has_method("take_damage") or body.name == "Astronaut":
#		body.take_damage(damage)
#	queue_free()

func thrown():
	apply_impulse(Vector2.ZERO, speed)
