extends KinematicBody2D

var throw_velocity = 45
var velocity = Vector2.ZERO
var direction = -1
var damage = 45

onready var player = get_parent().get_parent().get_node("Player")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	look_at(player.global_position)
	velocity.x = throw_velocity
	velocity.y = 15
	
	velocity = move_and_slide(velocity.rotated(rotation))

func set_self_direction(new_dir):
	direction = new_dir
	if new_dir < 0:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true


func _on_Detection_area_body_entered(body):
	if body.name == "Player":
		queue_free()
		


func _on_Detection_area_area_shape_entered(area_id, area, area_shape, local_shape):
	print(area.name)
	if area.name != "Area2D":
		queue_free()
