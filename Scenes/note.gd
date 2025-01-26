extends Node3D

@export_multiline var note_text:String

func _on_interactable_interacted() -> void:
	Utils.get_player().INPUT = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Utils.get_ui().find_child("HUD").find_child("Note").text = note_text
	Utils.get_ui().find_child("HUD").find_child("Note").visible = true
