extends SceneTree

const GameManagerScript = preload("res://scripts/game_manager.gd")
const BookMenuScene = preload("res://BookMenu/bookmenu.tscn")
const PAGE_NAMES := [
	"AnimalPage1", "AnimalPage2", "AnimalPage3", "AnimalPage4", "AnimalPage5", "AnimalPage6",
	"ArtifactPage1", "ArtifactPage2", "ArtifactPage3", "ArtifactPage4", "ArtifactPage5", "ArtifactPage6",
]
const CONTENTS_CALLBACKS := [
	"_on_animal_1_pressed", "_on_animal_2_pressed", "_on_animal_3_pressed",
	"_on_animal_4_pressed", "_on_animal_5_pressed", "_on_animal_6_pressed",
	"_on_artifacts_1_pressed", "_on_artifacts_2_pressed", "_on_artifacts_3_pressed",
	"_on_artifacts_4_pressed", "_on_artifacts_5_pressed", "_on_artifacts_6_pressed",
]

var _failures := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var state = GameManagerScript.new()
	state.name = "GameManager"
	root.add_child(state)

	_expect(state.request_toggle_camera(), "Camera opens from the default state")
	_expect(state.is_camera_open(), "Camera state is retained")
	state.open_pause()
	_expect(paused, "Pause freezes the scene tree")
	_expect(state.is_camera_open(), "Pause preserves an active camera")
	state.resume_game()
	_expect(not paused, "Resume unfreezes when no journal is open")
	_expect(state.is_camera_open(), "Resume restores the active camera state")
	state.open_pause()
	state.open_pause_settings()
	_expect(state.is_pause_settings_open(), "Settings opens inside Pause")
	state.close_pause_settings()
	_expect(not state.is_pause_settings_open() and state.is_pause_open(), "Escape-equivalent returns Settings to Pause")
	state.resume_game()

	_expect(state.request_toggle_camera(), "Camera can close before opening Journal")
	_expect(state.request_open_journal(), "Journal opens when no camera is active")
	_expect(paused, "Journal freezes the scene tree during its opening transition")
	state.complete_journal_transition(true)
	_expect(state.is_journal_open() and paused, "Open Journal remains a modal pause")
	_expect(not state.request_toggle_camera(), "Camera cannot open over Journal")
	state.open_pause()
	_expect(state.is_pause_open() and state.is_journal_open(), "Pause preserves Journal underneath")
	state.resume_game()
	_expect(paused and state.is_journal_open(), "Closing Pause restores Journal's pause")
	_expect(state.request_close_journal(), "Journal begins closing")
	state.complete_journal_transition(false)
	_expect(not paused, "Closing Journal resumes the scene tree")

	_expect(state.request_toggle_camera(), "Camera reopens for transition checks")
	_expect(state.begin_camera_transition(), "Camera transition starts from active camera mode")
	_expect(not state.request_open_journal(), "Journal is rejected during a camera transition")
	_expect(not state.request_toggle_camera(), "Camera toggle is rejected during a camera transition")
	state.end_camera_transition()
	state.set_camera_closeup_active(true)
	_expect(not state.request_toggle_camera(), "Camera cannot close while a close-up needs its exit action")
	state.set_camera_closeup_active(false)
	_expect(state.request_toggle_camera(), "Camera closes after the close-up exits")

	var book = BookMenuScene.instantiate()
	root.add_child(book)
	for page_index in PAGE_NAMES.size():
		book.call(CONTENTS_CALLBACKS[page_index])
		_expect(book.get_node(PAGE_NAMES[page_index]).visible, "Contents entry opens its mapped page")
		_expect(_visible_page_count(book) == 1, "Contents entry shows exactly one page")
		book.call("show_page", page_index)
		_expect(_visible_page_count(book) == 1, "Journal renders one page at a time")
		_expect(book.get_node(PAGE_NAMES[page_index]).visible, "Journal renders its requested page")
		_expect(book.get_node("PageTraversal/Before").disabled == (page_index == 0), "Previous state matches the first-page boundary")
		_expect(book.get_node("PageTraversal/Next").disabled == (page_index == PAGE_NAMES.size() - 1), "Next state matches the last-page boundary")
		if page_index < PAGE_NAMES.size() - 1:
			book.call("_on_next_pressed")
			_expect(book.get_node(PAGE_NAMES[page_index + 1]).visible, "Next traverses to the following page")
			_expect(_visible_page_count(book) == 1, "Next leaves exactly one page visible")
		book.call("show_page", page_index)
		if page_index > 0:
			book.call("_on_before_pressed")
			_expect(book.get_node(PAGE_NAMES[page_index - 1]).visible, "Previous traverses to the preceding page")
			_expect(_visible_page_count(book) == 1, "Previous leaves exactly one page visible")
		book.call("show_page", page_index)
		book.call("_on_back_button_pressed")
		_expect(book.get_node("TableOfContents").visible, "Contents entry returns to the table of contents")
		_expect(_visible_page_count(book) == 0, "Contents hides every page")
		_expect(book.current_page == page_index, "Contents retains the selected page")
	book.call("show_page", 0)
	_expect(book.get_node("PageTraversal/Before").disabled, "Journal disables Previous on its first page")
	book.call("show_page", PAGE_NAMES.size() - 1)
	_expect(book.get_node("PageTraversal/Next").disabled, "Journal disables Next on its last page")
	book.call("show_table_of_contents")
	_expect(book.get_node("TableOfContents").visible, "Journal Back returns to the table of contents")
	_expect(_visible_page_count(book) == 0, "Journal hides all pages at the table of contents")
	root.remove_child(book)
	book.free()

	paused = false
	root.remove_child(state)
	state.free()
	quit(_failures)

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("Game state flow test failed: %s" % message)

func _visible_page_count(book: Node) -> int:
	var count := 0
	for page_name in PAGE_NAMES:
		if book.get_node(page_name).visible:
			count += 1
	return count
