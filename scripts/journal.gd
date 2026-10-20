extends CanvasLayer

var tween: Tween
var hidden_offset: Vector2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hidden_offset = Vector2(0, get_viewport().get_visible_rect().size.y)
	offset = hidden_offset
	visible = false
	GameManager.journal_visibility_requested.connect(_on_journal_visibility_requested)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_journal_visibility_requested(is_open: bool) -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)

	if is_open:
		visible = true
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "offset", Vector2.ZERO, 0.375)
		tween.tween_callback(func(): GameManager.complete_journal_transition(true))
	else:
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(self, "offset", hidden_offset, 0.375)
		tween.tween_callback(func(): visible = false)
		tween.tween_callback(func(): GameManager.complete_journal_transition(false))

func _on_viewport_size_changed() -> void:
	hidden_offset = Vector2(0, get_viewport().get_visible_rect().size.y)
	if not visible:
		offset = hidden_offset
