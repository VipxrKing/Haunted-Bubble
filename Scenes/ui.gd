extends CanvasLayer

var tween1:Tween
var tween2:Tween
var curr_vis_state:bool = false

var in_game:bool = false
var paused: bool = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("PAUSE"):
		if in_game:
			if paused:
				unpause()
			else:
				pause()

func tween_stamina_bars(vis:bool):
	if curr_vis_state != vis:
		curr_vis_state = vis
	else: return
	if is_instance_valid(tween1):
		tween1.kill()
		tween2.kill()
	tween1 = create_tween()
	if vis: tween1.tween_property($HUD/StaminaBar,"modulate:a",1.0,0.5)
	else: tween1.tween_property($HUD/StaminaBar,"modulate:a",0.0,0.5)
	tween2 = create_tween()
	if vis: tween2.tween_property($HUD/StaminaBar2,"modulate:a",1.0,0.5)
	else: tween2.tween_property($HUD/StaminaBar2,"modulate:a",0.0,0.5)


func pause():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = true
	get_tree().paused = true
	$HUD.visible = false
	$PauseMenu.visible = true
	$PauseMenu/ColorRect/AnimationPlayer.play("IN")

func unpause():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	paused = false
	get_tree().paused = false
	$HUD.visible = true
	$PauseMenu.visible = false
	$PauseMenu/ColorRect/AnimationPlayer.play("OUT")
	

func death():
	in_game = false
	$HUD.visible = false
	$PauseMenu.visible = false
	
func death_finish():
	$DeathScreen.visible = true
	$DeathScreen/ColorRect/AnimationPlayer.play("IN")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func update_keys():
	$HUD/Keys.text = str(Utils.get_player().keys) + "/5"

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_resume_pressed() -> void:
	unpause()

func _on_main_menu_pressed() -> void:
	Utils.get_scene_manager().transition_to_overlay_scene("res://Scenes/main_menu.tscn")
	$DeathScreen.visible = false
	$WinScreen.visible = false
	$DeathScreen/ColorRect/AnimationPlayer.play("OUT")
	unpause()

func _on_close_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$HUD/Note.visible = false
	Utils.get_player().INPUT = true
