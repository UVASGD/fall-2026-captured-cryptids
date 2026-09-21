extends Camera2D

@export var follow_speed_keys: float = 750.0
@export var follow_speed_cursor: float = 100.0

const WRAP_LEFT := -2900.0
const WRAP_RIGHT := 2900.0

var target := Vector2.ZERO   # Virtual target the camera follows

func _ready():
	# Camera2D must NOT smooth for this test
	position_smoothing_enabled = false
	drag_horizontal_enabled = false
	drag_vertical_enabled = false
	
func _process(delta: float) -> void:
	var dir := Vector2.ZERO

	# Disallow movement if UI blocking screen
	if GameManager.ui_block: return

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
