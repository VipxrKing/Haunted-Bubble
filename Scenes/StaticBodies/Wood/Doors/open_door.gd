extends Node3D

@onready var animation:AnimationPlayer = self.find_child("AnimationPlayer")
var open:bool = false

func _on_interactable_interacted() -> void:
	if open:
		animation.play("close")
		open = false
	else:
		animation.play("open")
		open = true
		
