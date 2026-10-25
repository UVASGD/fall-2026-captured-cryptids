extends Camera2D

@export var follow_speed_keys := 750.0
@export var zoom_duration := 0.5
@export_range(1.0, 2.0, 0.05) var closeup_framing_margin := 1.2
@export var minimum_closeup_zoom := 0.5
@export var maximum_closeup_zoom := 20.0
@export var fade_rect: ColorRect
@export var main_background_node: Sprite2D
@export var closeup_background_texture: Texture2D

const WRAP_LEFT := -3500.0
const WRAP_RIGHT := 3500.0

enum CloseupState { IDLE, ENTERING, ACTIVE, EXITING }

var target := Vector2.ZERO
var _closeup_state := CloseupState.IDLE
var _transition: Tween
var _pre_closeup_position := Vector2.ZERO
var _pre_closeup_target := Vector2.ZERO
var _pre_closeup_zoom := Vector2.ONE
var _pre_closeup_texture: Texture2D

func _ready() -> void:
	position_smoothing_enabled = false
	drag_horizontal_enabled = false
	drag_vertical_enabled = false
	# Horizontal travel is bounded by WRAP_LEFT/WRAP_RIGHT jumps, not by Camera2D limits;
	# leaving the limits in place clamps the view and creates dead zones near the edges.
	limit_left = -10000000
	limit_right = 10000000
	target = position
	if fade_rect:
		fade_rect.modulate.a = 0.0

func _process(delta: float) -> void:
	if GameManager.is_gameplay_input_locked() or _closeup_state != CloseupState.IDLE:
		return

	var direction := Vector2.ZERO
	if Input.is_action_pressed("pan_right"):
		direction.x += 1.0
	if Input.is_action_pressed("pan_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("pan_down"):
		direction.y += 1.0
	if Input.is_action_pressed("pan_up"):
		direction.y -= 1.0

	if direction != Vector2.ZERO:
		target += direction.normalized() * follow_speed_keys * delta

	target.x = wrapf(target.x, WRAP_LEFT, WRAP_RIGHT)
	target.y = clamp(target.y, limit_top, limit_bottom)
	position = target

func transition_to_closeup(rect: Rect2) -> bool:
	if _closeup_state != CloseupState.IDLE or not GameManager.begin_camera_transition():
		return false

	_closeup_state = CloseupState.ENTERING
	_pre_closeup_position = position
	_pre_closeup_target = target
	_pre_closeup_zoom = zoom
	_pre_closeup_texture = main_background_node.texture if main_background_node else null

	var target_center := rect.get_center()
	target = target_center
	_kill_transition()
	_transition = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_transition.tween_property(self, "position", target_center, zoom_duration)
	_transition.parallel().tween_property(self, "zoom", _calculate_closeup_zoom(rect), zoom_duration)
	if fade_rect:
		_transition.parallel().tween_property(fade_rect, "modulate:a", 1.0, zoom_duration)
	_transition.tween_callback(_apply_closeup_background)
	if fade_rect:
		_transition.tween_property(fade_rect, "modulate:a", 0.0, zoom_duration)
	_transition.tween_callback(_finish_enter_closeup)
	return true

func transition_back_to_hallway() -> bool:
	if _closeup_state != CloseupState.ACTIVE or not GameManager.begin_camera_transition():
		return false

	_closeup_state = CloseupState.EXITING
	_kill_transition()
	_transition = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if fade_rect:
		_transition.tween_property(fade_rect, "modulate:a", 1.0, zoom_duration)
	_transition.tween_callback(_restore_background)
	_transition.tween_property(self, "position", _pre_closeup_position, zoom_duration)
	_transition.parallel().tween_property(self, "zoom", _pre_closeup_zoom, zoom_duration)
	if fade_rect:
		_transition.parallel().tween_property(fade_rect, "modulate:a", 0.0, zoom_duration)
	_transition.tween_callback(_finish_exit_closeup)
	return true

func _calculate_closeup_zoom(rect: Rect2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	var safe_size := Vector2(maxf(rect.size.x, 1.0), maxf(rect.size.y, 1.0))
	var fit_zoom := minf(viewport_size.x / safe_size.x, viewport_size.y / safe_size.y)
	var zoom_value := clampf(fit_zoom / closeup_framing_margin, minimum_closeup_zoom, maximum_closeup_zoom)
	return Vector2.ONE * zoom_value

func _apply_closeup_background() -> void:
	if main_background_node and closeup_background_texture:
		main_background_node.texture = closeup_background_texture

func _restore_background() -> void:
	if main_background_node:
		main_background_node.texture = _pre_closeup_texture

func _finish_enter_closeup() -> void:
	_closeup_state = CloseupState.ACTIVE
	GameManager.end_camera_transition()
	GameManager.set_camera_closeup_active(true)

func _finish_exit_closeup() -> void:
	target = _pre_closeup_target
	_closeup_state = CloseupState.IDLE
	GameManager.set_camera_closeup_active(false)
	GameManager.end_camera_transition()

func _kill_transition() -> void:
	if _transition and _transition.is_valid():
		_transition.kill()
