extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(randi_range(1,3)).timeout
	anim_loop()

# Loops animation
func anim_loop() -> void:
	while true:
		if !GameManager.ui_block:
			play("default")
			var wait_low = 1
			var wait_high = 3
			var wait = randi_range(wait_low, wait_high)
			await get_tree().create_timer(wait).timeout
		else:
			pause()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
