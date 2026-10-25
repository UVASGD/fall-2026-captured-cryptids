@tool
extends AnimatedSprite2D
class_name Creature

enum State { ZOOMED_OUT, ZOOMED_IN, CAPTURED }
var current_state: State = State.ZOOMED_OUT

@onready var collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hitbox: CreatureHitbox = $Hitbox

@export var camera: Camera2D

# NEW CHECKBOX: Toggle this ON only for your special Mothbush node!
@export var has_closeup_transition: bool = false 

@export var is_cryptid: bool = false
@export var wait_low: int = 4
@export var wait_high: int = 8

@export var collision_position: Vector2:
	set(value):
		collision_position = value
		_update_collision()

@export var collision_size: Vector2:
	set(value):
		collision_size = value
		_update_collision()

var is_captured: bool = false;
		
func _update_collision():
	if !collision_shape: 
		collision_shape = $Hitbox/CollisionShape2D
	collision_shape.position.x = collision_position.x
	collision_shape.position.y = collision_position.y
	var shape = collision_shape.shape
	if shape is not RectangleShape2D: return
	shape.size = collision_size

func _when_clicked() -> void:
	if Engine.is_editor_hint(): return

	# 1. PATH FOR NORMAL CREATURES (Only highlight, do NOT touch the camera)
	if !has_closeup_transition:
		modulate = Color.RED if is_cryptid else Color.GREEN
		is_captured = true
		return # Stop here so the camera isn't affected

	# 2. PATH FOR SPECIAL MOTHBUSH (Use the camera transition state machine)
	if !camera: return
	match current_state:
		State.ZOOMED_OUT:
			var zoom_rect: Rect2 = collision_shape.global_transform * collision_shape.shape.get_rect()
			if camera.transition_to_closeup(zoom_rect):
				current_state = State.ZOOMED_IN
			
		State.ZOOMED_IN:
			modulate = Color.RED if is_cryptid else Color.GREEN
			is_captured = true
			current_state = State.CAPTURED
			
			# Pause-respecting timers: the exit must not fire while a menu is open.
			await get_tree().create_timer(0.8, false).timeout
			while is_inside_tree() and not camera.transition_back_to_hallway():
				await get_tree().create_timer(0.1, false).timeout

func _process(_delta: float) -> void:
	pass

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_update_collision()
		
	hitbox.captured.connect(_when_clicked);
		
	await get_tree().create_timer(randi_range(1,3), false).timeout
	anim_loop()

func anim_loop() -> void:
	while is_inside_tree():
		play("default")
		var wait = randi_range(wait_low, wait_high)
		await get_tree().create_timer(wait, false).timeout
