extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func evil_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://BookMenu/evilbookmenu.tscn")


func _on_animal_1_pressed() -> void:
	get_tree().change_scene_to_file("res://BookMenu/BookDescription.tscn")
