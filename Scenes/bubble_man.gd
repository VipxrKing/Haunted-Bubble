extends CharacterBody3D

@onready var navigation_agent_3d:NavigationAgent3D = $NavigationAgent3D

@export var WALKING_SPEED:float = 4.0
@export var RUN_SPEED:float = 7.0

var mission_complete:bool = false

var SPEED:float = 4.0

const FALLING_SPEED:float = 9.8
var ACCELERATION:float = 10.0

var direction:Vector3 = Vector3()

var playerref:PhysicsBody3D
var target_point:Vector3

var body_rot_tween:Tween

func _ready() -> void:
	playerref = Utils.get_player()

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= FALLING_SPEED
	if !mission_complete: navigation_agent_3d.target_position = playerref.global_position
	face_to()
	direction = (navigation_agent_3d.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(direction*SPEED,ACCELERATION * delta)
	move_and_slide()
	
func face_to(to_player:bool = false) -> void:
	if body_rot_tween:
		body_rot_tween.kill()
	body_rot_tween = create_tween()
	
	var target_angle
	
	if !to_player: target_angle = atan2(velocity.x, velocity.z)
	else: target_angle = atan2(playerref.global_position.x - global_position.x, playerref.global_position.z - global_position.z)
	
	var atan = lerp_angle(rotation.y, target_angle, 1.0)
	var duration
	
	if !to_player: duration = atan - rotation.y
	else: duration = (atan - rotation.y) * 2
	
	body_rot_tween.tween_property(self,"rotation:y",atan,absf(duration/5))


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		$SongPlayer.playing = false
		mission_complete = true
		$"Mesh/AnimationPlayer".play("WALK")
		navigation_agent_3d.target_position = playerref.find_child("Marker3D").global_position
		$WalkTimer.stop()
		$RunTimer.stop()
		SPEED = WALKING_SPEED
		body.death()
		await get_tree().create_timer(1.0).timeout
		if $"Mesh/AnimationPlayer".current_animation != "IDLE": _on_navigation_agent_3d_navigation_finished()

func _on_random_timer_timeout() -> void:
	$RandomTimer.wait_time = randf_range(2,6)
	$BubbleAudio.playing = true
	
func _on_bubble_audio_finished() -> void:
	$RandomTimer.start()

func _on_run_timer_timeout() -> void:
	$"Mesh/AnimationPlayer".play("WALK")
	var tween = create_tween()
	tween.tween_property($SongPlayer,"volume_db",-80,1.0)
	SPEED = WALKING_SPEED
	$WalkTimer.start()

func _on_walk_timer_timeout() -> void:
	$"Mesh/AnimationPlayer".play("RUN")
	var tween = create_tween()
	tween.tween_property($SongPlayer,"volume_db",-25,1.0)
	SPEED = RUN_SPEED
	$RunTimer.start()


func _on_navigation_agent_3d_navigation_finished() -> void:
	if mission_complete: $"Mesh/AnimationPlayer".play("IDLE")
