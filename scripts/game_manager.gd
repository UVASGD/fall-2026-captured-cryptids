extends Node

## The one source of truth for UI and gameplay state.
## UI scripts request changes here; no scene is allowed to set state flags directly.

signal journal_visibility_requested(is_open: bool)
signal pause_changed(is_open: bool)
signal pause_settings_changed(is_open: bool)
signal camera_active_changed(is_active: bool)
signal camera_transition_changed(is_active: bool)
signal camera_closeup_changed(is_active: bool)
signal state_changed

# Creature Scene
const CREATURE_SCENE: PackedScene = preload("res://scenes/creature.tscn")

# Global camera progress
var pictures_taken: int = 0
var pictures_remaining: int = 10
var camera_battery: float = 100.0

# Global journal progress
var recorded_cryptids: Array = []
var recorded_creatures: Array = []
var cryptids_taken: int = 0
var creatures_taken: int = 0

# Global environment progress
var time_of_day: int = 0

var _journal_open := false
var _journal_transitioning := false
var _pause_open := false
var _pause_settings_open := false
var _camera_open := false
var _camera_transitioning := false
var _camera_closeup_active := false

func _ready() -> void:
	# This node must continue receiving Escape and journal input while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Placeholder spawns, in the future put these spawns into actual levels
	await get_tree().process_frame
	spawn_creature("deer", false, false, -2125.0, 153.0)
	spawn_creature("deer", true, false, -1289.0, 160.0)
	spawn_creature("palemoth", false, false, -3512.0, -167.0)
	spawn_creature("palemoth", true, false, -3052.0, -330.0)
	spawn_creature("blackwalnut", false, false, -404.0, 14.0)
	spawn_creature("blackwalnut", true, false, 634.0, 8.0)
	# spawn_creature("mothbush", false, true, -2800.0, 251.89)
	# Not touching mothbush, trying to spawn it breaks the camera zoom in

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if event is InputEventKey and event.is_echo():
		return

	if event.is_action_pressed("ui_cancel"):
		if _pause_open:
			if _pause_settings_open:
				close_pause_settings()
			else:
				resume_game()
		else:
			open_pause()
		get_viewport().set_input_as_handled()
		return

	# Pause owns all input until it is dismissed. Journal controls are still available
	# because their buttons receive GUI events before this callback.
	if _pause_open:
		return

	if event.is_action_pressed("journal"):
		request_toggle_journal()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("camera"):
		request_toggle_camera()
		get_viewport().set_input_as_handled()

func is_journal_open() -> bool:
	return _journal_open

func is_journal_transitioning() -> bool:
	return _journal_transitioning

func is_pause_open() -> bool:
	return _pause_open

func is_pause_settings_open() -> bool:
	return _pause_settings_open

func is_camera_open() -> bool:
	return _camera_open

func is_camera_transitioning() -> bool:
	return _camera_transitioning

func is_camera_closeup_active() -> bool:
	return _camera_closeup_active

func is_gameplay_input_locked() -> bool:
	return _pause_open or _journal_open or _journal_transitioning or _camera_transitioning

func can_capture_with_camera() -> bool:
	return _camera_open and not is_gameplay_input_locked()

func open_pause() -> void:
	if _pause_open:
		return
	_pause_open = true
	_pause_settings_open = false
	_sync_scene_tree_pause()
	pause_changed.emit(true)
	state_changed.emit()

func resume_game() -> void:
	if not _pause_open:
		return
	_pause_open = false
	_pause_settings_open = false
	pause_changed.emit(false)
	_sync_scene_tree_pause()
	state_changed.emit()

func open_pause_settings() -> void:
	if not _pause_open or _pause_settings_open:
		return
	_pause_settings_open = true
	pause_settings_changed.emit(true)
	state_changed.emit()

func close_pause_settings() -> void:
	if not _pause_settings_open:
		return
	_pause_settings_open = false
	pause_settings_changed.emit(false)
	state_changed.emit()

func request_toggle_journal() -> void:
	if _journal_open:
		request_close_journal()
	else:
		request_open_journal()

func request_open_journal() -> bool:
	if _pause_open or _journal_open or _journal_transitioning or _camera_open or _camera_transitioning:
		return false
	_journal_open = true
	_journal_transitioning = true
	_sync_scene_tree_pause()
	journal_visibility_requested.emit(true)
	state_changed.emit()
	return true

func request_close_journal() -> bool:
	if not _journal_open or _journal_transitioning:
		return false
	_journal_transitioning = true
	journal_visibility_requested.emit(false)
	state_changed.emit()
	return true

## Called by Journal after its opening/closing tween has actually completed.
func complete_journal_transition(is_open: bool) -> void:
	if not _journal_transitioning:
		return
	if is_open and not _journal_open:
		return
	_journal_transitioning = false
	if not is_open:
		_journal_open = false
	_sync_scene_tree_pause()
	state_changed.emit()

func request_toggle_camera() -> bool:
	if _pause_open or _journal_open or _journal_transitioning or _camera_transitioning or _camera_closeup_active:
		return false
	_camera_open = not _camera_open
	camera_active_changed.emit(_camera_open)
	state_changed.emit()
	return true

## Returns false if another modal UI or camera movement transition owns gameplay input.
func begin_camera_transition() -> bool:
	if not _camera_open or is_gameplay_input_locked():
		return false
	_camera_transitioning = true
	camera_transition_changed.emit(true)
	state_changed.emit()
	return true

func end_camera_transition() -> void:
	if not _camera_transitioning:
		return
	_camera_transitioning = false
	camera_transition_changed.emit(false)
	state_changed.emit()

func set_camera_closeup_active(is_active: bool) -> void:
	if _camera_closeup_active == is_active:
		return
	_camera_closeup_active = is_active
	camera_closeup_changed.emit(is_active)
	state_changed.emit()

func _sync_scene_tree_pause() -> void:
	get_tree().paused = _pause_open or _journal_open
	
func spawn_creature(creature_name: String, cryptid: bool, close_up: bool, x: float, y: float) -> Creature:
	var root := get_tree().current_scene.find_child("CreatureRoot", true, false)
	if root == null:
		return null
	
	var frames_path := "res://assets/resources/" + creature_name + "_animations.tres"
	var creature: Creature = CREATURE_SCENE.instantiate()
	creature.creature_name = creature_name
	creature.is_cryptid = cryptid
	creature.has_closeup_transition = close_up
	creature.sprite_frames = load(frames_path)
	creature.position = Vector2(x, y)
	
	# Hardcoded Camera Hitboxes:
	var shape_node = creature.get_node("Hitbox/CollisionShape2D")
	var hitbox_x: float
	var hitbox_y: float
	var rectangle_x: float
	var rectangle_y: float
	if creature_name == "deer":
		hitbox_x = 1.117
		hitbox_y = 0.352
		rectangle_x = 6.609
		rectangle_y = 7.547
	elif creature_name == "palemoth":
		hitbox_x = 0.121
		hitbox_y = 0.137
		rectangle_x = 4.281
		rectangle_y = 5.516
	elif creature_name == "blackwalnut":
		hitbox_x = 0.063
		hitbox_y = 0.0
		rectangle_x = 4.281
		rectangle_y = 10.813
	elif creature_name == "mothbush":
		hitbox_x = -0.066
		hitbox_y = 0.098
		rectangle_x = 3.875
		rectangle_y = 5.391
	creature.collision_size = Vector2(rectangle_x, rectangle_y)
	creature.collision_position = Vector2(hitbox_x, hitbox_y)
	
	root.add_child(creature)
	return creature
