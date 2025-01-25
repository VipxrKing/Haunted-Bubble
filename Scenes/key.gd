extends RigidBody3D

func _on_interactable_interacted() -> void:
	Utils.get_player().keys += 1
	Utils.get_ui().update_keys()
	queue_free()
