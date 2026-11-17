extends Control

@onready var film_counter: RichTextLabel = $FilmCounter

var camera_open := false

func _ready() -> void:
	visible = false
	film_counter.bbcode_enabled = true
	GameManager.film_changed.connect(_on_film_changed)
	_on_film_changed(GameManager.film_remaining, GameManager.max_film)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_camera"):
		camera_open = not camera_open
		visible = camera_open
	elif camera_open and event.is_action_pressed("shutter"):
		take_shot()

func _on_film_changed(remaining: int, max_film: int) -> void:
	var color := "white" if remaining > 5 else "red"
	film_counter.text = "[right][color=%s]%02d[/color] / %02d[/right]" % [color, remaining, max_film]

func take_shot() -> void:
	if not GameManager.can_take_photo():
		return # play a "no film" sound here
	GameManager.use_film()
	# your existing capture / flash / sound code goes here
