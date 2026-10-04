extends CanvasLayer

var is_open: bool = false
var tween: Tween
var hidden_offset: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hidden_offset = Vector2(0, get_viewport().get_visible_rect().size.y)
	offset = hidden_offset
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameManager._pause_open or GameManager._camera_open:
		return
	if Input.is_action_just_pressed("journal"): 
		_toggle_journal()
		
func _toggle_journal() -> void:
	is_open = !is_open
	GameManager._journal_open = is_open
	GameManager.journal_animation = true
	
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)

	if is_open:
		visible = true
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "offset", Vector2.ZERO, 0.375)
	else:
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(self, "offset", hidden_offset, 0.375)
		tween.tween_callback(func(): visible = false)
	tween.tween_callback(func(): GameManager.journal_animation = false)
