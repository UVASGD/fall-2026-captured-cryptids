extends Area2D
class_name CreatureHitbox

signal captured

func _clicked():
	captured.emit()
