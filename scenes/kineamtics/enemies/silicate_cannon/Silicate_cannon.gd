extends KinematicBody2D
signal update_health(new_value)
signal killed()
signal hurt()

onready var health_pack = preload("res://scenes/props/health_pack/health_pack.tscn")
export var max_health = 20
var health = max_health
export var time_interval = 3
var total_shot = 0
export var no_of_cannon_shots = 3
onready var cross_hair = $Position2D
onready var neon_bullet = preload("res://scenes/props/neon_bullet/neon_bullet.tscn")
onready var ray_cast = $RayCast2D
onready var animationPlayer = $AnimationPlayer
onready var hp_bar = $hpbar
onready var tween = $Tween
export var direction = -1
var can_fire = true
var active = true

enum states {idle, attack, hurt, dead}
var state 
# Called when the node enters the scene tree for the first time.
func _ready():
	hp_bar.max_value = max_health
	hp_bar.value = health
	state = states.idle
	if scale.x == -1:
		hp_bar.rect_scale.x = -1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match_state(state)
	
	
func match_state(curr_state):
	match curr_state:
		states.idle:
			
			animationPlayer.play("idle")
			if ray_cast.is_colliding() and ray_cast.get_collider().name == "Player":
				state = states.attack
		states.attack:
			if can_fire == false and health > 0:
				animationPlayer.play("attack")
			else:
				animationPlayer.play("idle")
			fire(direction)
		states.hurt:
			animationPlayer.play("hurt")
			yield(animationPlayer, "animation_finished")
			state = states.idle
		states.dead:
			kill()
				
		

func fire(dir):
	if ray_cast.is_colliding() and ray_cast.get_collider().name == "Player":
		var bullet_instance = neon_bullet.instance()
		yield(get_tree().create_timer(0.5), 'timeout')
		if active == true:
			if can_fire == true:
				bullet_instance.set_self_direction(dir)
				add_child(bullet_instance)
				bullet_instance.global_position = cross_hair.global_position
				total_shot += 1
				can_fire = false
				yield(get_tree().create_timer(1), "timeout")
				can_fire = true

			elif total_shot >= no_of_cannon_shots:
				can_fire = false
				active = false
				yield(get_tree().create_timer(time_interval), "timeout")
				active = true
				total_shot = 0
				can_fire = true
		

func spawn_health_pack():
	var health_pack_instance = health_pack.instance()
	add_child(health_pack_instance)
	health_pack_instance.position.x = cross_hair.position.x

func kill():
	ray_cast.enabled = false
	$CollisionShape2D.disabled = true
	$hpbar.hide()
	
	
func take_damage(damage_amount):
	if health > 0:
		health = health - damage_amount
		emit_signal("update_health", health)
	else:
		active = false
		emit_signal("killed")


func _on_Silicate_cannon_update_health(new_value):
	state = states.hurt
	tween.interpolate_property(hp_bar, "value", hp_bar.value, new_value, 0.4, tween.TRANS_QUAD, tween.EASE_OUT)
	tween.start()


func _on_Silicate_cannon_killed():
	spawn_health_pack()
	animationPlayer.play("dead")
	state = states.dead


func _on_Silicate_cannon_hurt():
	animationPlayer.play("hurt")
