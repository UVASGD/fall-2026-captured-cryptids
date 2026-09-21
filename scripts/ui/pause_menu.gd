extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"): 
		if GameManager._journal_open:
			GameManager._journal_open = false
		visible = !visible
		GameManager._pause_open = visible
