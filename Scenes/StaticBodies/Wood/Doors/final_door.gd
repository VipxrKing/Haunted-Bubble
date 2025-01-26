extends Node3D

@onready var animation:AnimationPlayer = self.find_child("AnimationPlayer")

func _on_player_detector_player_entered() -> void:
	var tkeys = Utils.get_player().keys
	if tkeys == 5:
		animation.play("open")
		Utils.get_ui().find_child("WinScreen").visible = true
		Utils.get_player().set_collision_layer_value(2,false)
		Utils.get_player().INPUT = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
