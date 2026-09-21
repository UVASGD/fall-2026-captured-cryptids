@tool
extends AnimatedSprite2D
class_name Creature

@onready var collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hitbox: CreatureHitbox = $Hitbox

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
	modulate = Color.RED if is_cryptid else Color.GREEN
	is_captured = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Avoid gameplay logic in-editor
	if Engine.is_editor_hint():
		return
		
	hitbox.captured.connect(_when_clicked);
		
	await get_tree().create_timer(randi_range(1,3)).timeout
	anim_loop()

# Loops animation
func anim_loop() -> void:
	while true:
		if !GameManager.ui_block:
			play("default")
			var wait = randi_range(wait_low, wait_high)
			await get_tree().create_timer(wait).timeout
		else:
			pause()
