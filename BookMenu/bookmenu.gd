extends Node2D

const FIRST_PAGE := 0
const LAST_PAGE := 11

var current_page := -1
var pages: Array[Control] = []

@onready var journal_placeholder: Sprite2D = $JournalPlaceholder
@onready var table_of_contents: Control = $TableOfContents
@onready var page_traversal: Control = $PageTraversal
@onready var previous_button: BaseButton = $PageTraversal/Before
@onready var next_button: BaseButton = $PageTraversal/Next

func _ready() -> void:
	pages.assign([
		$AnimalPage1,
		$AnimalPage2,
		$AnimalPage3,
		$AnimalPage4,
		$AnimalPage5,
		$AnimalPage6,
		$ArtifactPage1,
		$ArtifactPage2,
		$ArtifactPage3,
		$ArtifactPage4,
		$ArtifactPage5,
		$ArtifactPage6,
	])
	journal_placeholder.show()
	show_table_of_contents()

func show_table_of_contents() -> void:
	_hide_all_pages()
	table_of_contents.show()
	page_traversal.hide()

func show_page(page_index: int) -> void:
	if page_index < FIRST_PAGE or page_index > LAST_PAGE:
		return
	current_page = page_index
	table_of_contents.hide()
	_hide_all_pages()
	pages[current_page].show()
	page_traversal.show()
	previous_button.disabled = current_page == FIRST_PAGE
	next_button.disabled = current_page == LAST_PAGE

func _hide_all_pages() -> void:
	for page in pages:
		page.hide()

func _on_back_button_pressed() -> void:
	show_table_of_contents()

func _on_before_pressed() -> void:
	if current_page > FIRST_PAGE:
		show_page(current_page - 1)

func _on_next_pressed() -> void:
	if current_page < LAST_PAGE:
		show_page(current_page + 1)

func _on_animal_1_pressed() -> void:
	show_page(0)

func _on_animal_2_pressed() -> void:
	show_page(1)

func _on_animal_3_pressed() -> void:
	show_page(2)

func _on_animal_4_pressed() -> void:
	show_page(3)

func _on_animal_5_pressed() -> void:
	show_page(4)

func _on_animal_6_pressed() -> void:
	show_page(5)

func _on_artifacts_1_pressed() -> void:
	show_page(6)

func _on_artifacts_2_pressed() -> void:
	show_page(7)

func _on_artifacts_3_pressed() -> void:
	show_page(8)

func _on_artifacts_4_pressed() -> void:
	show_page(9)

func _on_artifacts_5_pressed() -> void:
	show_page(10)

func _on_artifacts_6_pressed() -> void:
	show_page(11)
