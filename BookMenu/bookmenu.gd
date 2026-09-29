extends Node2D
var current_page = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$JournalPlaceholder.show()
	$TableOfContents.show()
	$PageTraversal.hide()
	$AnimalPage1.hide()
	$AnimalPage2.hide()
	$AnimalPage3.hide()
	$AnimalPage4.hide()
	$AnimalPage5.hide()
	$AnimalPage6.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animal_1_pressed() -> void:
	$TableOfContents.hide()
	$AnimalPage1.show()
	$PageTraversal.show()
	
					


func _on_back_button_pressed() -> void:
	$AnimalPage1.hide()
	$AnimalPage2.hide()
	$AnimalPage3.hide()
	$AnimalPage4.hide()
	$AnimalPage5.hide()
	$AnimalPage6.hide()
	$PageTraversal.hide()
	$TableOfContents.show()
	
	
	pass # Replace with function body.


func _on_animal_2_pressed() -> void:
	$TableOfContents.hide()
	$AnimalPage2.show()
	$PageTraversal.show()
	$PageTraversal/Before.show()
	
	pass # Replace with function body.


func _on_animal_3_pressed() -> void:
	$TableOfContents.hide()
	$AnimalPage3.show()
	$PageTraversal.show()
	
	pass # Replace with function body.


func _on_animal_4_pressed() -> void:
	$TableOfContents.hide()
	$AnimalPage4.show()
	$PageTraversal.show()
	pass # Replace with function body.


func _on_animal_5_pressed() -> void:
	$TableOfContents.hide()
	$AnimalPage5.show()
	$PageTraversal.show()
	pass # Replace with function body.


func _on_animal_6_pressed() -> void:
	$TableOfContents.hide()
	$AnimalPage6.show()
	$PageTraversal.show()
	pass # Replace with function body.
	
func hide_all_pages() -> void:
	$AnimalPage1.hide()
	$AnimalPage2.hide()
	$AnimalPage3.hide()
	$AnimalPage4.hide()
	$AnimalPage5.hide()
	$AnimalPage6.hide()


func show_current_page() -> void:
	hide_all_pages()

	if current_page == 1:
		$AnimalPage1.show()
	elif current_page == 2:
		$AnimalPage2.show()
	elif current_page == 3:
		$AnimalPage3.show()
	elif current_page == 4:
		$AnimalPage4.show()
	elif current_page == 5:
		$AnimalPage5.show()
	elif current_page == 6:
		$AnimalPage6.show()


func _on_next_pressed() -> void:
	if current_page < 6:
		current_page += 1
		show_current_page()


func _on_before_pressed() -> void:
	if current_page > 1:
		current_page -= 1
		show_current_page()
