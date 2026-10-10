extends Camera2D

@export var follow_speed_keys: float = 750.0
@export var follow_speed_cursor: float = 100.0
@export var zoom_duration: float = 0.5  # Time in seconds for the zoom transition

const WRAP_LEFT := -2900.0
const WRAP_RIGHT := 2900.0

var target := Vector2.ZERO   # Virtual target the camera follows
var default_zoom: Vector2
var default_position: Vector2
var is_focusing: bool = false # Tracks if we are currently locked onto a creature
var curr_default: Vector2

func _ready():
	# Camera2D must NOT smooth for this test
	position_smoothing_enabled = false
	drag_horizontal_enabled = false
	drag_vertical_enabled = false
	
	# Save the camera's baseline settings on startup
	default_zoom = zoom
	default_position = position
	target = position
	
func _process(delta: float) -> void:
	# Disallow movement if UI blocking screen OR if we are focused/zooming on a creature
	if GameManager.ui_block or is_focusing: return

	var dir := Vector2.ZERO

	# Keyboard input
	if Input.is_action_pressed("pan_right"):
		dir.x += 1
	if Input.is_action_pressed("pan_left"):
		dir.x -= 1
	if Input.is_action_pressed("pan_down"):
		dir.y += 1
	if Input.is_action_pressed("pan_up"):
		dir.y -= 1
		
	# Keyboard movement
	if dir != Vector2.ZERO:
		target += dir.normalized() * follow_speed_keys * delta
		
	# Horizontal wrap
	target.x = wrapf(target.x, WRAP_LEFT, WRAP_RIGHT)
	# Vertical clamp
	target.y = clamp(target.y, limit_top, limit_bottom)
	# Camera follows target
	position = target

## This is the function called by your Creature script when captured
func focus_on_rectangle(rect: Rect2) -> void:
	is_focusing = true
	
	# 1. Get the center point of the creature's hitbox
	var target_center: Vector2 = rect.get_center()
	
	# 2. Get your game window's current resolution size
	var viewport_size: Vector2 = get_viewport_rect().size
	
	# 3. Calculate how much we need to zoom for width and height to fit the screen
	var zoom_factor_x: float = viewport_size.x / rect.size.x
	var zoom_factor_y: float = viewport_size.y / rect.size.y
	
	# 4. Use the smaller factor so the creature fits entirely on screen.
	# Multiplied by 0.5 to leave a clear frame/margin around the monster.
	var final_zoom_value: float = min(zoom_factor_x, zoom_factor_y) * 0.01
	var target_zoom: Vector2 = Vector2(final_zoom_value, final_zoom_value)
	
	# 5. Keep our pan tracking variables updated so it doesn't snap post-zoom
	target = target_center
	
	# 6. Smoothly animate both position and zoom simultaneously using a Tween
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_center, zoom_duration)
	tween.tween_property(self, "zoom", target_zoom, zoom_duration)
	
	curr_default = target_center

## Call this function to smoothly snap back to your default layout
func reset_camera() -> void:
	# Synchronize our virtual target back to the default layout center
	target = curr_default
	
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target, zoom_duration)
	tween.tween_property(self, "zoom", default_zoom, zoom_duration)
	
	# Allow movement controls again when the transition finishes
	tween.chain().tween_callback(func(): is_focusing = false)
