extends Node

# Global variables
var pictures_taken = 0
var pictures_remaining = 10
var cryptids_taken = 0
var creatures_taken = 0

var _journal_open: bool = false
var _pause_open: bool = false
var _camera_open: bool = false

# Is journal open?
var journal_open: bool = false:
	get:
		return _journal_open
	set(value):
		_journal_open = value
		_update_ui_block()

# Is pause open?
var pause_open: bool = false:
	get:
		return _pause_open
	set(value):
		_pause_open = value
		_update_ui_block()

# Is camera open?
var camera_open: bool = false:
	get:
		return _camera_open
	set(value):
		_camera_open = value

# Tells if game screen is blocked by UI elements
var ui_block: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _update_ui_block() -> void:
	ui_block = _journal_open or _pause_open
