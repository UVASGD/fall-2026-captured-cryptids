extends AnimatedSprite2D

@onready var camera_hitbox: Area2D = $Area2D

var overlapped_areas: Array[Node2D] = []
var brightness_modifier = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
	camera_hitbox.area_entered.connect(_on_area_entered)
	camera_hitbox.area_exited.connect(_on_area_exited)

func _on_area_entered(node: Node2D):
	if node is not CreatureHitbox: return;
	var creature: Creature = node.get_parent()
	if creature.is_captured: return;
	overlapped_areas.append(creature)
	if visible:
		creature.modulate = Color(1 + brightness_modifier, 1 + brightness_modifier, 1 + brightness_modifier, 1.0)

func _on_area_exited(node: Node2D):
	if node is not CreatureHitbox: return;
	var creature: Creature = node.get_parent()
	if creature.is_captured: return;
	overlapped_areas.erase(creature)
	creature.modulate = Color.WHITE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameManager._pause_open:
		return
	if Input.is_action_just_pressed("camera"): 
		visible = !visible
		GameManager._camera_open = visible
		if !visible:
			for node in overlapped_areas:
				if node is not Creature: 
					continue
				if node.is_captured: 
					continue
				node.modulate = Color.WHITE
		else:
			for node in overlapped_areas:
				if node is not Creature: 
					continue
				if node.is_captured: 
					continue
				node.modulate = Color(1 + brightness_modifier, 1 + brightness_modifier, 1 + brightness_modifier, 1.0)

	var camera = get_viewport().get_camera_2d()
	if camera:
		global_position = camera.get_global_mouse_position()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			for node in overlapped_areas:
				if node is not Creature: 
					continue
				print(node.to_string() + " was captured by the camera!")
				if node.has_method("_when_clicked"):
					node._when_clicked();
