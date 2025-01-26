extends Node3D

@onready var animation:AnimationPlayer = self.find_child("AnimationPlayer")
@export var door:bool = false
var open:bool = false

func _on_interactable_interacted() -> void:
	if open:
		if door:
			disable_collision(false)
		animation.play("close")
		open = false
	else:
		if door:
			disable_collision(true)
		animation.play("open")
		open = true

func disable_collision(state:bool) -> void:
	for i in get_children():
		if i is StaticBody3D:
			for j in i.get_children():
				if j is CollisionShape3D:
					j.disabled = state
