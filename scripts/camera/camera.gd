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
	if visible and not creature.is_captured:
		_highlight(creature)

func _on_area_exited(node: Node2D):
	if node is not CreatureHitbox:
		return
	var creature: Creature = node.get_parent()
	overlapped_areas.erase(creature)
	if creature != null and not creature.is_captured:
		creature.modulate = Color.WHITE

func _on_camera_active_changed(is_active: bool) -> void:
	visible = is_active
	if is_active:
		for creature in overlapped_areas:
			if is_instance_valid(creature) and not creature.is_captured:
				_highlight(creature)
	else:
		_clear_highlights()

func _highlight(creature: Creature) -> void:
	creature.modulate = Color(1.0 + brightness_modifier, 1.0 + brightness_modifier, 1.0 + brightness_modifier, 1.0)

func _clear_highlights() -> void:
	for creature in overlapped_areas:
		if is_instance_valid(creature) and not creature.is_captured:
			creature.modulate = Color.WHITE

func _physics_process(_delta: float) -> void:
	if not GameManager.is_camera_open():
		return
	var camera = get_viewport().get_camera_2d()
	if camera:
		global_position = camera.get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	if event.button_index != MOUSE_BUTTON_LEFT or not GameManager.can_capture_with_camera():
		return
	for creature in overlapped_areas:
		if not is_instance_valid(creature) or creature.is_captured:
			continue
		creature._when_clicked()
		get_viewport().set_input_as_handled()
		return
