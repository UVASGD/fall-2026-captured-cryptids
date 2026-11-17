extends RichTextLabel

const LOW_FILM := 5
const PULSE_TIME := 0.4       # seconds per fade (white -> red, red -> white)
const SLIDE_DISTANCE := 16.0  # pixels the new number falls
const SLIDE_TIME := 0.25      # seconds for the slide

var _pulse_tween: Tween
var _slide_tween: Tween
var _base_y := 0.0
var _shown_text := ""

func _ready() -> void:
	bbcode_enabled = true
	_base_y = position.y
	GameManager.film_changed.connect(_on_film_changed)
	_on_film_changed(GameManager.film_remaining, GameManager.max_film)

func _on_film_changed(remaining: int, max_film: int) -> void:
	var new_text := "[right]%02d/%02d[/right]" % [remaining, max_film]

	# Color / pulse logic
	if remaining == 0:
		_stop_pulse()
		_set_color(Color.RED)
	elif remaining <= LOW_FILM:
		_start_pulse()
	else:
		_stop_pulse()
		_set_color(Color.WHITE)

	# Slide the new number in (skipped on the very first update)
	var changed := _shown_text != "" and _shown_text != new_text
	text = new_text
	_shown_text = new_text
	if changed:
		_slide_in()

func _slide_in() -> void:
	if _slide_tween:
		_slide_tween.kill()
	position.y = _base_y - SLIDE_DISTANCE
	modulate.a = 0.0
	_slide_tween = create_tween().set_parallel(true)
	_slide_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_slide_tween.tween_property(self, "position:y", _base_y, SLIDE_TIME)
	_slide_tween.tween_property(self, "modulate:a", 1.0, SLIDE_TIME)

func _start_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		return
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_method(_set_color, Color.WHITE, Color.RED, PULSE_TIME)
	_pulse_tween.tween_method(_set_color, Color.RED, Color.WHITE, PULSE_TIME)

func _stop_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null

func _set_color(c: Color) -> void:
	add_theme_color_override("default_color", c)
