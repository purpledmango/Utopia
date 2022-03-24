extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func _on_Play_pressed():
	get_tree().change_scene("res://scenes/enviroment/Ground Base.tscn")


func _on_Quit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	pass # Replace with function body.
