extends CanvasLayer

@onready var settingsMenu: Control = $SettingsMenu
@onready var pauseMenu: Control = $PauseMenu
@onready var settingsButton: Button = $PauseMenu/Settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
	settingsButton.pressed.connect(_settings_clicked)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"): 
		if (settingsMenu.visible):
			pauseMenu.visible = true
			settingsMenu.visible = false
			return
		visible = !visible
		GameManager.pause_open = visible

func _settings_clicked() -> void:
	pauseMenu.visible = false;
	settingsMenu.visible = true;
