extends Control

@onready var static_toggle: CheckButton = %StaticToggle
@onready var music_slider: HSlider = %MusicSlider
@onready var sound_slider: HSlider = %SoundSlider
@onready var exit_button: Button = %ExitButton

func _ready() -> void:
	static_toggle.button_pressed = GameManager._static_toggle
	music_slider.value = GameManager._music_level
	sound_slider.value = GameManager._sound_level

	static_toggle.toggled.connect(_on_static_toggled)
	music_slider.value_changed.connect(_on_music_changed)
	sound_slider.value_changed.connect(_on_sound_changed)
	exit_button.pressed.connect(GameManager.close_pause_settings)

func _on_static_toggled(is_on: bool) -> void:
	GameManager._static_toggle = is_on

func _on_music_changed(value: float) -> void:
	GameManager._music_level = value

func _on_sound_changed(value: float) -> void:
	GameManager._sound_level = value
