extends TextureButton

signal custom_pressed

func _on_mouse_entered() -> void:
	$Idler.play("Idle")

func _on_mouse_exited() -> void:
	$Idler.play("RESET")

func _on_pressed() -> void:
	$AnimationPlayer.play("CLOSE")
	await get_tree().create_timer(1.2).timeout
	custom_pressed.emit()
	$AnimationPlayer.play("OPEN")
