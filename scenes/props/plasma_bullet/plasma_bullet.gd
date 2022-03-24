extends Area2D

onready var animationPlayer = $AnimationPlayer
var speed = 150
var velocity = Vector2.ZERO
var damage = 25
var direction = 1

func _physics_process(delta):
	animationPlayer.play("fire")
	velocity = Vector2(speed* delta * direction, 0)
	translate(velocity)
	
func set_self_direction(new_dir):
	direction = new_dir
	if new_dir < 0:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
		

func _on_plasma_bullet_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
			
	queue_free()
	


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
