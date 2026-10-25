extends Node

const MainCameraScript = preload("res://scripts/camera/main_cam.gd")
const MainCameraScene = preload("res://scenes/main_camera.tscn")
const CreatureScene = preload("res://scenes/creature.tscn")
const MothBushFrames = preload("res://assets/resources/mothbush_normal_animation.tres")
const ForestScene = preload("res://scenes/Forest.tscn")
const HallwayTexture = preload("res://assets/art/creatures/background/BG_Draft_1_Top_Layer.png")
const CloseupTexture = preload("res://assets/art/creatures/background/4_87.png")

var _failures := 0

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_expect(GameManager.request_toggle_camera(), "Camera state opens for close-up checks")
	var camera = MainCameraScript.new()
	var fade_rect := ColorRect.new()
	var background := Sprite2D.new()
	var original_position := Vector2(120.0, -45.0)
	var original_target := original_position
	var original_zoom := Vector2(1.4, 1.4)
	var focus_rect := Rect2(Vector2(200.0, 80.0), Vector2(40.0, 60.0))
	camera.position = original_position
	camera.zoom = original_zoom
	camera.zoom_duration = 0.05
	camera.fade_rect = fade_rect
	camera.main_background_node = background
	camera.closeup_background_texture = CloseupTexture
	background.texture = HallwayTexture
	camera.add_child(fade_rect)
	camera.add_child(background)
	add_child(camera)
	camera.target = original_target

	camera.transition_to_closeup(focus_rect)
	await get_tree().create_timer(0.04, true).timeout
	GameManager.open_pause()
	var paused_position: Vector2 = camera.position
	var paused_fade: float = fade_rect.modulate.a
	await get_tree().create_timer(0.1, true).timeout
	_expect(get_tree().paused and GameManager.is_camera_transitioning(), "Pause freezes an active camera transition")
	_expect(camera.position.is_equal_approx(paused_position), "Camera position remains frozen while paused")
	_expect(is_equal_approx(fade_rect.modulate.a, paused_fade), "Transition fade remains frozen while paused")
	GameManager.resume_game()
	await get_tree().create_timer(0.3, true).timeout
	_expect(not GameManager.is_camera_transitioning(), "Camera transition completes after resume")
	_expect(GameManager.is_camera_closeup_active(), "Close-up state activates after its transition")
	_expect(background.texture == CloseupTexture, "Close-up applies its configured background")
	var fit_zoom := minf(get_viewport().get_visible_rect().size.x / focus_rect.size.x, get_viewport().get_visible_rect().size.y / focus_rect.size.y)
	var expected_zoom := clampf(fit_zoom / camera.closeup_framing_margin, camera.minimum_closeup_zoom, camera.maximum_closeup_zoom)
	_expect(camera.zoom.is_equal_approx(Vector2.ONE * expected_zoom), "Close-up zoom frames its target using the viewport margin")

	camera.transition_back_to_hallway()
	await get_tree().create_timer(0.3, true).timeout
	_expect(camera.position.is_equal_approx(original_position), "Close-up restores the exact camera position")
	_expect(camera.zoom.is_equal_approx(original_zoom), "Close-up restores the exact camera zoom")
	_expect(camera.target.is_equal_approx(original_target), "Close-up restores the exact camera target")
	_expect(background.texture == HallwayTexture, "Close-up restores the hallway background")
	_expect(is_zero_approx(fade_rect.modulate.a), "Close-up exit clears its transition fade")
	_expect(not GameManager.is_camera_closeup_active(), "Close-up state clears after exit")
	GameManager.request_toggle_camera()
	camera.queue_free()
	await get_tree().process_frame
	await _test_camera_hitbox_alignment()
	await _test_overlay_process_modes()
	get_tree().quit(_failures)

func _test_camera_hitbox_alignment() -> void:
	GameManager.request_toggle_camera()
	var camera = MainCameraScene.instantiate()
	add_child(camera)
	camera.make_current()
	camera.position = Vector2.ZERO
	camera.zoom = Vector2.ONE
	var world_layer := CanvasLayer.new()
	world_layer.layer = 0
	world_layer.follow_viewport_enabled = true
	add_child(world_layer)
	var moth_bush = CreatureScene.instantiate()
	moth_bush.sprite_frames = MothBushFrames
	moth_bush.position = Vector2.ZERO
	moth_bush.scale = Vector2(8.0, 8.0)
	moth_bush.camera = camera
	moth_bush.has_closeup_transition = true
	moth_bush.collision_position = Vector2(-0.6, 0.0)
	moth_bush.collision_size = Vector2(5.28, 5.69)
	world_layer.add_child(moth_bush)
	Input.warp_mouse(get_viewport().get_visible_rect().size / 2.0)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	var camera_tool: Node2D = camera.get_node("CameraLayer/Camera_Anim")
	var camera_hitbox: Area2D = camera_tool.get_node("Area2D")
	var expected_world_position: Vector2 = camera.get_global_mouse_position()
	_expect(camera_tool.global_position.is_equal_approx(expected_world_position), "Camera reticle matches world mouse position")
	moth_bush.global_position = expected_world_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(camera_tool.overlapped_areas.has(moth_bush), "Camera hitbox overlaps the configured Moth Bush hitbox")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	camera_tool.call("_input", click)
	_expect(moth_bush.current_state == Creature.State.ZOOMED_IN, "Camera overlap click starts the Moth Bush close-up")
	GameManager.end_camera_transition()
	GameManager.set_camera_closeup_active(false)
	GameManager.request_toggle_camera()
	moth_bush.queue_free()
	camera.queue_free()
	world_layer.queue_free()
	await get_tree().process_frame

func _test_overlay_process_modes() -> void:
	var forest = ForestScene.instantiate()
	var journal: CanvasLayer = forest.get_node("Journal")
	var pause_menu: CanvasLayer = forest.get_node("Pause Menu")
	var world_camera: Camera2D = forest.get_node("MainCamera")
	var creature: Node = forest.get_node("Main Background/CreatureRoot/Deer_Normal")
	_expect(journal.get_script() != null, "Forest scene contains its Journal controller")
	_expect(pause_menu.process_mode == Node.PROCESS_MODE_ALWAYS, "Pause controls process while the tree is paused")
	_expect(world_camera.process_mode == Node.PROCESS_MODE_INHERIT, "World camera remains pausable")
	_expect(creature.process_mode == Node.PROCESS_MODE_INHERIT, "Creature animation remains pausable")
	forest.remove_child(journal)
	forest.remove_child(pause_menu)
	forest.free()
	add_child(journal)
	add_child(pause_menu)
	await get_tree().process_frame
	_expect(journal.process_mode == Node.PROCESS_MODE_ALWAYS, "Journal controls process while the tree is paused")
	_expect(GameManager.request_open_journal(), "Journal opens over the forest scene")
	await get_tree().create_timer(0.5, true).timeout
	_expect(get_tree().paused and journal.visible, "Journal opens while gameplay is frozen")
	GameManager.open_pause()
	_expect(pause_menu.visible, "Pause overlay remains responsive above Journal")
	GameManager.resume_game()
	_expect(get_tree().paused and journal.visible, "Resuming Pause preserves the open Journal")
	_expect(GameManager.request_close_journal(), "Journal closes after Pause resumes")
	await get_tree().create_timer(0.5, true).timeout
	_expect(not get_tree().paused and not journal.visible, "Closing Journal resumes forest processing")
	journal.queue_free()
	pause_menu.queue_free()
	await get_tree().process_frame

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("Camera close-up flow test failed: %s" % message)