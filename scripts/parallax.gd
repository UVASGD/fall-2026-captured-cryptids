extends Node2D

@export var parallax_amount: float = 0.5

var start_position: Vector2
var camera_start_position: Vector2

func _ready():
	start_position = global_position
	var camera := get_viewport().get_camera_2d()
	camera_start_position = camera.global_position if camera else Vector2.ZERO

func _process(_delta):
	var camera = get_viewport().get_camera_2d()

	if camera == null:
		return

	var camera_offset = camera.global_position - camera_start_position
	camera_offset.y -= camera_offset.y

	global_position = start_position + camera_offset * parallax_amount
