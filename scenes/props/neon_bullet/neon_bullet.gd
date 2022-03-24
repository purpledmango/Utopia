extends Area2D

var speed = 55
var damage = 25
var direction
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(Vector2(speed*direction * delta, 0))


func set_self_direction(new_dir):
	direction = new_dir
	if new_dir < 0:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_neon_bullet_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
		queue_free()
