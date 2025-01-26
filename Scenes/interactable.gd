extends Area3D
class_name Interactable

signal Interacted

func interact():
	if !$Timer.is_stopped():
		return
	else:
		$Timer.start()
		Interacted.emit()
	

func _on_timer_timeout() -> void:
	pass # Replace with function body.
