extends Node3D

var next_scene = null
var overlay_scene = null
var player_location = Vector3.ZERO
var player_direction = Vector2.ZERO

enum TransitionType {NEW_SCENE, MENU}
var transition_type = TransitionType.NEW_SCENE

var SceneLoaderThread:Thread = Thread.new()

signal finished_loading_thread
signal finished_loading_map

func load_scene():
	print("load_scene_start")
	var load_s = ResourceLoader.load_threaded_request(next_scene)
	await ResourceLoader.load_threaded_get_status(next_scene) == 3
	print("thread_scene_load_end")
	$CurrentScene.add_child(ResourceLoader.load_threaded_get(next_scene).instantiate())
	print("load_scene_end")
	return
	
func transition_to_scene(new_scene: String) -> void:
	unload_overlay()
	next_scene = new_scene
	transition_type = TransitionType.NEW_SCENE
	$TransitionLayer/AnimationPlayer.play("FadeBlack")
	await $TransitionLayer/AnimationPlayer.animation_finished
	transition()
	
func transition_to_overlay_scene(new_Scene:String) -> void:
	if $CurrentOverlay.get_child_count() > 0:
		$CurrentOverlay.get_child(0).queue_free()
	overlay_scene = new_Scene
	transition_type = TransitionType.MENU
	$TransitionLayer/AnimationPlayer.play("FadeBlack")
	await $TransitionLayer/AnimationPlayer.animation_finished
	transition()
	
func unload_overlay() -> void:
	for i in $CurrentOverlay.get_children():
		i.queue_free()
		
func transition() -> void:
	match transition_type:
		TransitionType.NEW_SCENE:
			var load_s = ResourceLoader.load_threaded_request(next_scene)
			if $CurrentScene.get_child_count() > 0:
				#var packed_scene = ResourceLoader.load_threaded_get(next_scene)
				#$CurrentScene.get_child(0).change_scene_to_packed(packed_scene)
				$CurrentScene.get_child(0).queue_free()
				await $CurrentScene.get_child(0).tree_exited
				await ResourceLoader.load_threaded_get_status(next_scene) == 3
			$CurrentScene.add_child(ResourceLoader.load_threaded_get(next_scene).instantiate())
			await ResourceLoader.load_threaded_get_status(next_scene) == 3
			await get_tree().create_timer(1.0).timeout
			#SceneLoaderThread.start(load_scene)
			#await get_tree().create_timer(0.5)
			#SceneLoaderThread.wait_to_finish()
			finished_loading_map.emit()
			Utils.get_ui().visible = true
			$TransitionLayer/AnimationPlayer.play("UnfadeBlack")
			await $TransitionLayer/AnimationPlayer.animation_finished
			Utils.get_ui().in_game = true
			Utils.get_ui().find_child("HUD").visible = true

		TransitionType.MENU:
			var load_s = ResourceLoader.load_threaded_request(overlay_scene)
			if $CurrentOverlay.get_child_count() > 0:
				$CurrentOverlay.get_child(0).queue_free()
			if $CurrentScene.get_child_count() > 0:
				$CurrentScene.get_child(0).queue_free()
				await $CurrentScene.get_child(0).tree_exited
			await ResourceLoader.load_threaded_get_status(overlay_scene) == 3
			$CurrentOverlay.add_child(load(overlay_scene).instantiate())
			Utils.get_ui().in_game = false
			Utils.get_ui().find_child("HUD").visible = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$TransitionLayer/AnimationPlayer.play("UnfadeBlack")
			
func hide_screen(duration:float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property($TransitionLayer/ScreenColor,"color:a",1,duration)
	
func show_screen(duration:float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property($TransitionLayer/ScreenColor,"color:a",0,duration)
