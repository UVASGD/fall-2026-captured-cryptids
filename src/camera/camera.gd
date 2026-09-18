extends AnimatedSprite2D

@onready var camera_hitbox: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameManager._pause_open:
		return
	if Input.is_action_just_pressed("camera"): 
		visible = !visible
		GameManager._camera_open = visible

	var camera = get_viewport().get_camera_2d()
	if camera:
		global_position = camera.get_global_mouse_position()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var areas = camera_hitbox.get_overlapping_areas();
			for node in areas:
				if node is not Area2D: 
					continue
				print(node.to_string() + " was captured by the camera!")
				if node.has_method("_when_clicked"):
					node._when_clicked();
