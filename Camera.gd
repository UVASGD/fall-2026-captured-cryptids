extends CanvasLayer

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
