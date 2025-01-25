extends RigidBody3D

func _on_interactable_interacted() -> void:
	Utils.get_player().add_lantern_battery(500)
	queue_free()
	
