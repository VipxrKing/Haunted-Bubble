extends Node3D

@onready var animation:AnimationPlayer = self.find_child("AnimationPlayer")

func _on_player_detector_player_entered() -> void:
	var tkeys = Utils.get_player().keysw
	if tkeys == 5:
		animation.play("open")
