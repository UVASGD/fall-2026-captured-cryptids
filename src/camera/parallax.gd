extends Node2D

@export var parallax_amount: float = 0.5

var start_position: Vector2
var camera_start_position: Vector2

func _ready():
	start_position = global_position
	camera_start_position = get_viewport().get_camera_2d().global_position

func _process(_delta):
	var camera = get_viewport().get_camera_2d()

	if camera == null:
		return

	var camera_offset = camera.global_position - camera_start_position

	global_position = start_position + camera_offset * parallax_amount
