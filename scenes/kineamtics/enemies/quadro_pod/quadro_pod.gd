extends KinematicBody2D

signal update_health(new_value)
signal killed()
signal hurt()
export(int) var total_step = 5
var step = 0
export var max_health = 75
onready var health = max_health
export var fire_interval = 1.2

var velocity = Vector2.ZERO
var chase_speed = 800
var speed = 1500
var GRAVITY = 180
var jump_power = -160
var UP = Vector2(0, -1)
var direction = -1
var can_fire = true

export var shards = 4

var shard = preload("res://scenes/props/shard/shard.tscn")
onready var animationPlayer = $AnimationPlayer
onready var crosshair = $crosshair
onready var sprite = $Sprite
onready var floor_detect = $detectFloor
onready var player = get_node("../../Player")
onready var health_bar = $hpbar
onready var tween = $Tween
onready var playerDetectLeft = $playerDetectRayLeft
onready var playerDetectRight = $playerDetectRayRight

var alert = preload("res://scenes/props/alert/alert.tscn")
var yellow_bullet_scene = preload("res://scenes/props/plasma_bullet/plasma_bullet.tscn")
var alert_intance = alert.instance()
####STATES#####
enum states {scout, chase, attack, hurt, dead}
var state

func _ready():
	health_bar.max_value = health
	state = states.scout
	health_bar.value = health

func _physics_process(delta):
	check_for_player()
	state_machine(state, delta)
	apply_gravity(delta)
	flip_sprite()
	apply_movement(delta)

# State Machine
func state_machine(curr_state, delta):
	match curr_state:
		states.scout:
			scout(delta)
			if velocity.x == 0 and health > 0:
				animationPlayer.play('idle')
			elif velocity.x != 0 and health > 0:
				animationPlayer.play('run')
		states.chase:
			chase(delta)
			if velocity.x == 0 and health > 0:
				animationPlayer.play('idle')
			elif velocity.x != 0 and health > 0:
				animationPlayer.play('run')
			
		states.attack:
			if health > 0:
				attack(direction)
			else:
				state = states.dead
			if health > 0 and velocity.x != 0:
				state = states.chase
				
		states.hurt:
			velocity.x = 0
			animationPlayer.play("hurt")
			yield(animationPlayer, "animation_finished")
			state = states.scout
		states.dead:
			velocity.x = 0
			velocity.y = 0
			kill()
			animationPlayer.play("dead")
			yield(animationPlayer, "animation_finished")
			$Sprite.hide()
			yield(get_tree().create_timer(12), "timeout")
			queue_free()
		
#Apply Gravity
func apply_gravity(delta):
	velocity.y += GRAVITY * delta

#Apply Movement
func apply_movement(delta):
			
	velocity = move_and_slide(velocity, UP)
	if is_on_wall():
		direction = direction * -1
		
	if floor_detect.is_colliding() == false and state != states.chase: 
		direction = direction * -1
		
	if direction == -1:
		floor_detect.position.x = -14.14
	elif direction == 1:
		floor_detect.position.x = 14.14

func attack(dir):
	var bullet = yellow_bullet_scene.instance()
	yield(get_tree().create_timer(0.5), 'timeout')
	if can_fire == true:
		can_fire = false
		velocity.x = 0
		animationPlayer.play("attack")
		if dir == 1:
			crosshair.position.x = 20
			bullet.set_self_direction(dir)
		elif dir == -1:
			crosshair.position.x = -20
			bullet.set_self_direction(dir)
		get_parent().add_child(bullet)
		bullet.position = crosshair.global_position
		yield(get_tree().create_timer(fire_interval), 'timeout')
		can_fire = true

func kill():
	playerDetectLeft.enabled = false
	playerDetectRight.enabled = false
	shard_spawnner()
	$CollisionShape2D.disabled = true
	$hpbar.hide()
	if alert_intance:
		remove_child(alert_intance)
	
func take_damage(damage_amount):
	if health > 0:
		health = health - damage_amount
		emit_signal("update_health", health)
		emit_signal("hurt")
		
	else:
		state = states.dead

func flip_sprite():
	if direction < 0:
		sprite.flip_h = false
	elif direction > 0:
		sprite.flip_h = true

func scout(delta):
	velocity.x = speed * direction * delta

func chase(delta):
	velocity.x = chase_speed * direction * delta
	
func check_for_player():
	if health > 0:
		if playerDetectLeft.is_colliding() and playerDetectLeft.get_collider().name == "Player": 
			direction = -1
			state = states.attack
		elif playerDetectRight.is_colliding() and playerDetectRight.get_collider().name == "Player":

			direction = 1
			state = states.attack
	else:
		state = states.dead


func shard_spawnner():
	var shard_instance = shard.instance()
	yield(get_tree().create_timer(0.5), "timeout")
	if shards > 0:
		add_child(shard_instance)
		shard_instance.position.x = crosshair.position.x * rand_range(-1,1) + rand_range(-10,30)
		shards = shards - 1
		

func _on_detection_area_body_entered(body):
	if body.name == "Player" and health > 0:
		add_child(alert_intance)
		alert_intance.position = $Position2D.position
		state = states.chase
		direction = sign(player.global_position.x - global_position.x)

func _on_detection_area_body_exited(body):
	if body.name == "Player" and health > 0:
		if alert_intance:
			remove_child(alert_intance)
		state = states.scout

func _on_quadro_pod_update_health(new_value):
	state = states.hurt
	tween.interpolate_property(health_bar, "value", health_bar.value, new_value, 0.2, tween.TRANS_QUAD, tween.EASE_OUT)
	tween.start()

func _on_quadro_pod_killed():
	state = states.dead

func _on_quadro_pod_hurt():
	animationPlayer.play('hurt')
	
	
	

