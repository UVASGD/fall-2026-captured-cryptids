extends AnimatedSprite2D

@onready var camera_hitbox: Area2D = $Area2D

var overlapped_areas: Array[Creature] = []
@export var brightness_modifier := 0.5

func _ready() -> void:
	visible = GameManager.is_camera_open()
	camera_hitbox.area_entered.connect(_on_area_entered)
	camera_hitbox.area_exited.connect(_on_area_exited)
	GameManager.camera_active_changed.connect(_on_camera_active_changed)

func _on_area_entered(node: Node2D):
	if node is not CreatureHitbox:
		return
	var creature: Creature = node.get_parent()
	if creature == null or overlapped_areas.has(creature):
		return
	overlapped_areas.append(creature)
	_refresh_highlight()

func _on_area_exited(node: Node2D):
	if node is not CreatureHitbox:
		return
	var creature: Creature = node.get_parent()
	overlapped_areas.erase(creature)
	if is_instance_valid(creature) and not creature.is_captured:
		creature.modulate = Color.WHITE
		creature.set_revealed(false)
	_refresh_highlight()

func _on_camera_active_changed(is_active: bool) -> void:
	visible = is_active
	_refresh_highlight()

## The single creature a click would capture: the one closest to the viewfinder centre.
## While zoomed on a creature, only that creature can be targeted.
func _target_creature() -> Creature:
	if not visible:
		return null
	var closeup := GameManager.is_camera_closeup_active()
	var best: Creature = null
	var best_distance := INF
	for creature in overlapped_areas:
		if not is_instance_valid(creature) or creature.is_captured:
			continue
		if closeup and creature.current_state != Creature.State.ZOOMED_IN:
			continue
		var distance := global_position.distance_squared_to(creature.collision_shape.global_position)
		if distance < best_distance:
			best_distance = distance
			best = creature
	return best

func _refresh_highlight() -> void:
	var target := _target_creature()
	for creature in overlapped_areas:
		if not is_instance_valid(creature) or creature.is_captured:
			continue
		var is_target := creature == target
		creature.modulate = _highlight_color() if is_target else Color.WHITE
		creature.set_revealed(is_target)

func _highlight_color() -> Color:
	var value := 1.0 + brightness_modifier
	return Color(value, value, value, 1.0)

func _physics_process(_delta: float) -> void:
	if not GameManager.is_camera_open():
		return
	var camera = get_viewport().get_camera_2d()
	if camera:
		global_position = camera.get_global_mouse_position()
	_refresh_highlight()

# _input, not _unhandled_input: a stray Control over a creature must never swallow captures.
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	print("Input")
	if event.button_index != MOUSE_BUTTON_LEFT or not GameManager.can_capture_with_camera():
		return
	var creature := _target_creature()
	if creature == null:
		return
	creature._when_clicked()
	get_viewport().set_input_as_handled()
