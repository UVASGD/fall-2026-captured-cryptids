extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_on_pressed)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	#var tween = create_tween()
	#tween.tween_property($CanvasLayer/ColorRect, "modulate:a", 1.0, 1.5).from(0.0)
	#await tween.finished	
	get_tree().quit()
	pass
