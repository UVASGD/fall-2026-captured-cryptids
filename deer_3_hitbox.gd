extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if GameManager.camera_open:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
				_when_clicked()

func _when_clicked() -> void:
	$Deer3C.modulate = Color.RED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
