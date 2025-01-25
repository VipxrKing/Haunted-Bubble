extends StaticBody3D

var open:bool = false
var busy:bool = false

func _on_interactable_interacted() -> void:
	if open:
		$Interactable/AnimationPlayer.play("close")
		open = false
	else:
		$Interactable/AnimationPlayer.play("open")
		open = true
