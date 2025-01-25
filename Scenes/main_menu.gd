extends Control

var starting_map:String = "res://Scenes/world.tscn"

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	Utils.get_scene_manager().transition_to_scene(starting_map)
