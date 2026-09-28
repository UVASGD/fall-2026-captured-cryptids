extends Node

# Global Camera Variables
var pictures_taken: int = 0
var pictures_remaining: int = 10
var camera_battery: float = 100.0

# Global Journal Variables
# Append the cryptid or creature's name into array, read from array for journal
var recorded_cryptids = []
var recorded_creatures = []
var cryptids_taken: int = 0
var creatures_taken: int = 0

# Global Boolean Toggles
var _journal_open: bool = false
var _pause_open: bool = false
var _camera_open: bool = false

# Journal Open Check - is journal open?
var journal_open: bool = false:
	get:
		return _journal_open
	set(value):
		_journal_open = value
		_update_ui_block()

# Pause Menu Open Check - is pause open?
var pause_open: bool = false:
	get:
		return _pause_open
	set(value):
		_pause_open = value
		_update_ui_block()

# Camera Open Check - is camera open?
var camera_open: bool = false:
	get:
		return _camera_open
	set(value):
		_camera_open = value

# Tells if game screen is blocked by UI elements
var ui_block: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _update_ui_block() -> void:
	ui_block = _journal_open or _pause_open
