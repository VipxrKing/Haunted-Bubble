extends Node

func get_scene_manager():
	return get_node("/root/SceneManager")

func get_player():
	return get_current_scene().find_child("Player")

func get_current_scene():
	return get_node("/root/SceneManager/CurrentScene").get_child(0)
	
func get_ui():
	return get_node("/root/SceneManager").find_child("UI")

func get_navigation_map():
	return get_current_scene().find_child("NavigationMap")

func custom_equal_aprox_vec3(val1:Vector3,val2:Vector3) -> bool:
	if (abs(val1.x - val2.x) < 0.2) and (abs(val1.y - val2.y) < 0.2) and (abs(val1.z - val2.z) < 0.2):
		return true
	else:
		return false

func custom_equal_aprox_float(val1:float,val2:float) -> bool:
	if (abs(val1) - abs(val2) < 0.2):
		return true
	else:
		return false
