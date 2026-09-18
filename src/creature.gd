@tool
extends AnimatedSprite2D

@onready var collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

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
		
func _update_collision():
	collision_shape.position = collision_position
	var shape = collision_shape.shape
	if shape is not RectangleShape2D: return
	shape.size = collision_size

func _when_clicked() -> void:
	modulate = Color.GREEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Avoid gameplay logic in-editor
	if Engine.is_editor_hint():
		return
		
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
