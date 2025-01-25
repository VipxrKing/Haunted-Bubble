extends CharacterBody3D

@onready var navigation_agent_3d:NavigationAgent3D = $NavigationAgent3D

@export var WALKING_SPEED:float = 8.0
@export var ROTATION_SPEED:float = 6.0

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
		velocity = velocity.lerp(direction*WALKING_SPEED,ACCELERATION * delta)
		move_and_slide()
	
		navigation_agent_3d.target_position = playerref.global_position
		face_to()
		direction = (navigation_agent_3d.get_next_path_position() - global_position).normalized()

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
	
	body_rot_tween.tween_property(self,"rotation:y",atan,absf(duration/3))


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.death()
