extends Camera2D

@export var follow_speed_keys: float = 750.0
@export var follow_speed_cursor: float = 100.0
@export var zoom_duration: float = 0.5  # Time in seconds for the zoom transition

# NEW FIELDS FOR MOTHBUSH TRANSITION
@export var fade_rect: ColorRect 
@export var main_background_node: CanvasItem 
@export var hallway_texture: Texture2D # Original hallway image
@export var closeup_background_texture: Texture2D # Closeup room image

const WRAP_LEFT := -3500.0
const WRAP_RIGHT := 3500.0

var target := Vector2.ZERO   
var default_zoom: Vector2
var default_position: Vector2
var is_focusing: bool = false 
var curr_default: Vector2

func _ready():
	position_smoothing_enabled = false
	drag_horizontal_enabled = false
	drag_vertical_enabled = false
	
	default_zoom = zoom
	default_position = position
	target = position
	
	if fade_rect:
		fade_rect.modulate.a = 0.0

func _process(delta: float) -> void:
	if GameManager.ui_block or is_focusing: return

	var dir := Vector2.ZERO
	if Input.is_action_pressed("pan_right"): dir.x += 1
	if Input.is_action_pressed("pan_left"): dir.x -= 1
	if Input.is_action_pressed("pan_down"): dir.y += 1
	if Input.is_action_pressed("pan_up"): dir.y -= 1
		
	if dir != Vector2.ZERO:
		target += dir.normalized() * follow_speed_keys * delta
		
	target.x = wrapf(target.x, WRAP_LEFT, WRAP_RIGHT)
	target.y = clamp(target.y, limit_top, limit_bottom)
	position = target


## RESTORED FOR NORMAL CREATURES: Instant single-click focus and zoom
func focus_on_rectangle(rect: Rect2) -> void:
	is_focusing = true
	
	var target_center: Vector2 = rect.get_center()
	var viewport_size: Vector2 = get_viewport_rect().size
	
	var zoom_factor_x: float = viewport_size.x / rect.size.x
	var zoom_factor_y: float = viewport_size.y / rect.size.y
	
	var final_zoom_value: float = min(zoom_factor_x, zoom_factor_y) * 0.01
	var target_zoom: Vector2 = Vector2(final_zoom_value, final_zoom_value)
	
	target = target_center
	curr_default = target_center
	
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_center, zoom_duration)
	tween.tween_property(self, "zoom", target_zoom, zoom_duration)


## MOTHBUSH CLICK 1: Zoom in, fade out, swap background behind mothbush, fade back in
func transition_to_closeup(rect: Rect2) -> void:
	is_focusing = true
	GameManager.ui_block = true 
	
	var target_center: Vector2 = rect.get_center()
	var viewport_size: Vector2 = get_viewport_rect().size
	
	var zoom_factor_x: float = viewport_size.x / rect.size.x
	var zoom_factor_y: float = viewport_size.y / rect.size.y
	var final_zoom_value: float = min(zoom_factor_x, zoom_factor_y) * 0.01
	var target_zoom: Vector2 = Vector2(final_zoom_value, final_zoom_value)
	
	target = target_center
	curr_default = target_center

	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_center, zoom_duration)
	tween.tween_property(self, "zoom", target_zoom, zoom_duration)
	if fade_rect:
		tween.tween_property(fade_rect, "modulate:a", 1.0, zoom_duration)
	
	tween.chain().tween_callback(func():
		if main_background_node and closeup_background_texture:
			main_background_node.texture = closeup_background_texture
	)
	
	var fade_in_tween: Tween = tween.chain().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if fade_rect:
		fade_in_tween.tween_property(fade_rect, "modulate:a", 0.0, zoom_duration)
		
	fade_in_tween.tween_callback(func():
		GameManager.ui_block = false
	)


## MOTHBUSH CLICK 2: Fade out, swap back to hallway image, zoom out smoothly
func transition_back_to_hallway() -> void:
	GameManager.ui_block = true
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if fade_rect:
		tween.tween_property(fade_rect, "modulate:a", 1.0, zoom_duration)
		
	tween.tween_callback(func():
		main_background_node.texture = null;
		position = curr_default
	)
	
	var zoom_out_tween: Tween = tween.chain().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	zoom_out_tween.tween_property(self, "zoom", default_zoom, zoom_duration)
	if fade_rect:
		zoom_out_tween.tween_property(fade_rect, "modulate:a", 0.0, zoom_duration)
		
	zoom_out_tween.chain().tween_callback(func():
		is_focusing = false
		GameManager.ui_block = false
	)

func reset_camera() -> void:
	target = curr_default
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target, zoom_duration)
	tween.tween_property(self, "zoom", default_zoom, zoom_duration)
	tween.chain().tween_callback(func(): is_focusing = false)
