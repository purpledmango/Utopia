extends KinematicBody2D

onready var animationPlayer = $shard_collect_area/AnimationPlayer
var points = 5
var velocity = Vector2()
var speed = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer.play("spawn")
	yield(animationPlayer, "animation_finished")
	animationPlayer.play("out")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y = 0.5
	move_and_collide(velocity)


func _on_shard_collect_area_body_entered(body):
	if body.name == "Player":
		body.shards_collector(points)
		queue_free()
