extends KinematicBody2D

signal update_health(new_value)
signal knockback()
signal killed()
signal c_pressed()

export var max_health = 200
onready var health = max_health  setget set_health
var velocity = Vector2.ZERO
var normal_speed = 70
var air_speed = 80
var speed = 0
var GRAVITY = 330
var fatal_height = 500
var jump_power = -210
var UP = Vector2(0, -1)
var knockback = 5
var direction = 1
var can_fire = true
var on_floor = false

enum states {idle, run, jump, fall, hurt, attack, dead}
var state

var all_shards = 0

onready var animationPlayer = $AnimationPlayer
onready var crosshair = $crosshair
onready var sprite = $Sprite
onready var health_bar = get_node("../HUD/Control/HBoxContainer/PlayerHealthBar")
onready var shard_no_updater = get_node("../HUD/Control/HBoxContainer/Sprite/Label")
onready var floor_detect = $RayCast2D
onready var left_button = $TouchControls/Control/left_button
onready var right_button = $TouchControls/Control/right_button
onready var jump_button = $TouchControls/Control/jump_button
onready var shoot_button = $TouchControls/Control/shoot_button
onready var c_button = $TouchControls/Control/c_button
# All the bullet instance
var yellow_bullet_scene = preload("res://scenes/props/yellow_plasma_bullet/yellow_plasma_bullet.tscn")
var red_plasma_bullet_scene = preload("res://scenes/props/red_plama_bullet/red_plasma_bullet.tscn")

func _ready():
	health_bar.max_value = max_health
	crosshair.position.x =  14.303
	state = states.idle

#Loops every one second
func _physics_process(delta):
	shard_no_updater.text  = str(all_shards)
#	print(velocity.x)
	player_input()
	state_machine(state)
	animation_state(state)
	apply_gravity(delta)
	apply_movement()

# Finite State machine
func state_machine(curr_state):
	match curr_state:
		states.idle:
#			print("idle")
			if not is_on_floor():
				if velocity.y < 0:
					state = states.jump
				elif velocity.y > 0:
					state = states.fall
			elif velocity.x != 0:
				state =  states.run

		states.run:
#			print("run")
			if not is_on_floor():
				if velocity.y < 0:
					state = states.jump
				elif velocity.y > 0:
					state = states.fall
			elif velocity.x == 0:
				state = states.idle
				
		states.jump:
			if is_on_floor():
				return states.idle
			elif velocity.y > 0:
				state =  states.fall
				
		states.fall:
#			velocity.x = (speed + air_speed )* direction
			if is_on_floor():
				state = states.idle
			elif velocity.y < 0:
				state = states.jump
		
		states.attack:
			if not is_on_floor():
				if velocity.y < 0:
					state = states.jump
				elif velocity.y > 0:
					state = states.fall
		states.hurt:
			if velocity.y < 0:
				animationPlayer.play("knockback_effect")
				velocity.x = 0
			elif velocity.y > 0:
#				print(sprite.material.)
				
				state = states.fall
		states.dead:
			kill()
			animationPlayer.play("dead")
			yield(animationPlayer,"animation_finished")
			get_tree().change_scene("res://scenes/ui/end_credits/EndScreen.tscn")
		
	
	return null

#Animation State Machine
func animation_state(curr_state):
	match curr_state:
		states.idle:
			animationPlayer.play("idle")

		states.run:
			animationPlayer.play("run")
				
		states.jump:
			animationPlayer.play("jump")
				
		states.fall:
			animationPlayer.play("fall")
		
		states.attack:
			animationPlayer.play("attack")

			
			
	return null

#Apply Gravity / Fall Damage / Changes SPEED based on Position
func apply_gravity(delta):
	
	# Checks and enbales fall damage
	if velocity.y > GRAVITY and velocity.y > fatal_height:
		floor_detect.enabled = true
		if floor_detect.is_colliding():
			die()
	else:
		floor_detect.enabled = false
		
	# Changes speed based on player position	
	if is_on_floor():
		speed = normal_speed
		on_floor = true
	else:
		on_floor = false
		speed = air_speed 
	
	# Enables Gravity	
	velocity.y += GRAVITY * delta

#Handling move and slide
func apply_movement():
	velocity = move_and_slide(velocity, UP)

# Handles Player INPUT
func player_input():
	#Movement Input LEFT / RIGHT
	if Input.is_action_pressed("ui_right") or right_button.pressed:
		$Sprite.flip_h = false
		direction = 1
		velocity.x = speed
	elif Input.is_action_pressed("ui_left") or left_button.pressed:
		$Sprite.flip_h = true
		direction = -1
		velocity.x = -speed
	else:
		velocity.x = 0
	#JUMP Input	
	if Input.is_action_pressed("jump") or jump_button.pressed :
		if on_floor == true:
			velocity.y = jump_power
			on_floor = false
		
	#ATTACK Input
	if Input.is_action_pressed("attack") or shoot_button.pressed:
		attack(direction)
		
	## C Touch button
	if c_button.pressed:
		emit_signal("c_pressed")

# Handles ATTACK Function
func attack(dir):
	var bullet = yellow_bullet_scene.instance()
	if can_fire == true:
		can_fire = false		
		if dir == 1:
			crosshair.position.x = 14.303
			bullet.set_self_direction(dir)
		elif dir == -1:
			crosshair.position.x = -14.303
			bullet.set_self_direction(dir)
		get_parent().add_child(bullet)
		bullet.position = crosshair.global_position
		yield(get_tree().create_timer(0.5), 'timeout')
		can_fire = true

# Handles instant KILL
func die():
	set_health(health - health)
	state = states.dead
	
# Handles DEAD logic
func kill():
	$Sprite.hide()
	$CollisionShape2D.disabled = true
	velocity = Vector2.ZERO
	
#Update the NO. of SHARDS
func shards_collector(shard_points):
	all_shards = all_shards + shard_points

#UPDATE DAMGE and HP 
func take_damage(damage_amount):
	set_health(health - damage_amount)
	emit_signal("knockback")
	 
func set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("update_health", value)
		if health == 0:
			state = states.dead

func _on_health_pack_update_new_health(new_amount):
	set_health(health + new_amount)

func _on_Player_knockback():
	if health > 0:
		state = states.hurt
		if direction == 1:
			velocity = Vector2(0, -125)
		elif direction == -1:
			velocity = Vector2(0, -125)
			
