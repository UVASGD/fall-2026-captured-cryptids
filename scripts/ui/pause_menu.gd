extends CanvasLayer

@onready var settings_menu: Control = $SettingsMenu
@onready var pause_menu: Control = $PauseMenu
@onready var settings_button: Button = $PauseMenu/Settings
@onready var return_button: Button = $PauseMenu/ReturnToGame

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = GameManager.is_pause_open()
	pause_menu.visible = true
	settings_menu.visible = false

	settings_button.pressed.connect(_settings_clicked)
	return_button.pressed.connect(GameManager.resume_game)
	GameManager.pause_changed.connect(_on_pause_changed)
	GameManager.pause_settings_changed.connect(_on_pause_settings_changed)

func _on_pause_changed(is_open: bool) -> void:
	visible = is_open
	if is_open:
		pause_menu.visible = true
		settings_menu.visible = false

func _on_pause_settings_changed(is_open: bool) -> void:
	pause_menu.visible = not is_open
	settings_menu.visible = is_open

func _settings_clicked() -> void:
	GameManager.open_pause_settings()
