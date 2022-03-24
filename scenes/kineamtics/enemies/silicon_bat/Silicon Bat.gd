extends KinematicBody2D

signal update_health(new_value)
signal killed()
export(int) var travel_distance = 5
var step = 0
export var max_health = 75
onready var health = max_health
export var fire_interval = 1.8
var velocity = Vector2.ZERO
var chase_speed = 800
var speed = 450
var GRAVITY = 180
var jump_power = -160
var UP = Vector2(0, -1)
var direction = -1
var can_fire = true
var is_jumping = true
var is_dead = false
var resting = true
var ditanceBetween = null
var min_distance = 65

onready var animationPlayer = $AnimationPlayer
onready var crosshair = $Position2D
onready var sprite = $Sprite
onready var raycastLeft = $RayCast2DLeft
onready var raycastRight = $RayCast2DRight
onready var player = get_node("../../Player")
onready var health_bar = $hpbar
onready var tween = $Tween
onready var playerDetectLeft = $playerDetectRayLeft
onready var playerDetectRight = $playerDetectRayRight
onready var alert = preload("res://scenes/props/alert/alert.tscn")
onready var alert_intance = alert.instance()

var bat_bullet = preload("res://scenes/props/bat_bullet/bat_bullet.tscn")

####STATES#####
enum states {scout, chase, attack, dead}
var state

func _ready():
	health_bar.max_value = health
	state = states.scout
	health_bar.value = health

func _physics_process(delta):
	chase(delta)
	attack(direction)
#	check_for_player()
#	state_machine(state, delta)
#	apply_gravity(delta)
	flip_sprite()
	apply_movement()

# State Machine
func state_machine(curr_state, delta):
	match curr_state:
		states.scout:
			scout(delta)
			if velocity.x == 0 and health > 0:
				animationPlayer.play('idle')
			elif velocity.x != 0 and health > 0:
				animationPlayer.play('idle')
		states.chase:
			chase(delta)
			if velocity.x == 0 and health > 0:
				animationPlayer.play('idle')
			elif velocity.x != 0 and health > 0:
				animationPlayer.play('idle')
			
		states.attack:
			if health > 0:
				attack(direction)
			else:
				state = states.dead
			if health > 0 and velocity.x != 0:
				state = states.chase
#			elif health < 0:
#				state = states.dead

		states.dead:
			kill()
			animationPlayer.play("dead")
			yield(animationPlayer, "animation_finished")
			queue_free()
		
#Apply Gravity
func apply_gravity(delta):
	velocity.y += GRAVITY * delta

#Apply Movement
func apply_movement():
	if is_on_wall():
		direction = direction * -1
		direction = -1
	velocity = move_and_slide(velocity, UP)

func attack(dir):
	var bullet = bat_bullet.instance()
	if can_fire == true:
		velocity.x = 0
		animationPlayer.play("attack")
		can_fire = false		
		if dir == 1:
			crosshair.position.x = 14
			bullet.set_self_direction(dir)
		
		elif dir == -1:
			crosshair.position.x = -14
			bullet.set_self_direction(dir)
		get_parent().add_child(bullet)
		bullet.position = crosshair.global_position
		yield(get_tree().create_timer(fire_interval), 'timeout')
		can_fire = true

func kill():
	$CollisionShape2D.disabled = true
	$hpbar.hide()
	velocity = Vector2.ZERO

func take_damage(damage_amount):
	if health > 0:
		health = health - damage_amount
		emit_signal("update_health", health)
	else:
		if state != states.dead:
			emit_signal("killed")
			kill()


func flip_sprite():
	if direction < 0:
		sprite.flip_h = false
	elif direction > 0:
		sprite.flip_h = true

func scout(delta):
	if resting == true:
		look_at(player.global_position) 

func chase(delta):
#	var distance_to_player = global_position.distance_to(player.global_position)
	var distance_to_player = (player.global_position - self.global_position)
	velocity.x = rand_range(56, distance_to_player.x) * direction
	
	
func check_for_player():
#	if playerDetectLeft.is_colliding() and health > 0: 
#		if playerDetectLeft.get_collider().name == "Player":
#			direction = -1
#			state = states.attack
#	elif playerDetectRight.is_colliding() and health > 0:
#		if playerDetectRight.get_collider().name == "Player":
#			direction = 1
#			state = states.attack

#	if $RayCast2D1.is_colliding() and health > 0:
#		if $RayCast2D1.get_collider().name == "Player":
#			state = states.attack
#		
	pass
		


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		direction = direction * sign(self.global_position.x - player.global_position.x)	
		state = states.chase


func _on_Area2D_body_exited(body):
	pass


func _on_Silicon_Bat_update_health(new_value):
	tween.interpolate_property(health_bar, "value", health_bar.value, new_value, 0.2, tween.TRANS_QUAD, tween.EASE_OUT)
	tween.start()


func _on_Silicon_Bat_killed():
	state = states.dead
