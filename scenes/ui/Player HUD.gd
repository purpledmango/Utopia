extends Control


onready var health_bar = $PlayerHealthBar
onready var tween = $Tween

var new_health

# Called when the node enters the scene tree for the first time.
func _ready():
	new_health = get_node("../../Player").health
	health_bar.value = new_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	var initial_value= health_bar.value
#	var final_value = initial_value + 5
	tween.interpolate_property(health_bar, "value", health_bar.value, new_health, 0.2, tween.TRANS_QUAD, tween.EASE_OUT)
	tween.start()

func _on_Player_update_health(new_value):
	new_health = new_value
