extends CanvasLayer
onready var health_bar = $Control/HBoxContainer/PlayerHealthBar
onready var tween = $Control/HBoxContainer/Tween
var new_health

func _ready():
	new_health = get_node("../Player").health
	health_bar.value = new_health

func _process(_delta):
	tween.interpolate_property(health_bar, "value", health_bar.value, new_health, 0.4, tween.TRANS_QUAD, tween.EASE_OUT)
	tween.start()

func _on_Player_update_health(new_value):
	new_health = new_value
