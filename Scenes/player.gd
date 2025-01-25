extends CharacterBody3D
class_name Player

@onready var head = $Head
#Flags3
var INPUT: bool = true

#Speeds
var CURRENT_SPEED: float = 5.0
const WALKING_SPEED: float = 6.0
const SPRINTING_SPEED: float = 10.0
const CROUNCHING_SPEED: float = 2.0
#Movement
const JUMP_VELOCITY: float = 8.0
var CROUCHING_DEPTH: float = 0.8
var LERP_SPEED: float = 10.0
#Input
var DIRECTION: Vector3 = Vector3.ZERO
const MOUSE_SENS: float = 0.3
var SENS_CONTROLLER: float = 5.0

var controller_input_dir: Vector2 = Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event) -> void:
	if INPUT:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
			head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _physics_process(delta) -> void:
	if INPUT:
		apply_controller_camera_rotation()
		
		if Input.is_action_pressed("CROUCH"):
			CURRENT_SPEED = CROUNCHING_SPEED
			head.position.y = lerp(head.position.y,1.8 - CROUCHING_DEPTH,delta*LERP_SPEED)
		else:
			head.position.y = lerp(head.position.y,1.8,delta*LERP_SPEED)
			if Input.is_action_pressed("SPRINT"):
				CURRENT_SPEED = SPRINTING_SPEED
				if DIRECTION:
					head.tween_fov(true)
				else:
					head.tween_fov(false)
			else:
				CURRENT_SPEED = WALKING_SPEED
				head.tween_fov(false)
		# Add the gravity.

		# Handle Jump.
		#if Input.is_action_pressed("JUMP") and is_on_floor():
			#velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("LEFT", "RIGHT", "FORWARD", "BACKWARD")
	
		DIRECTION = lerp(DIRECTION,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * LERP_SPEED)
	else:
		DIRECTION = Vector3.ZERO
		
	if not is_on_floor():
		velocity.y -= gravity * delta * 2.0

	if DIRECTION:
		velocity.x = DIRECTION.x * CURRENT_SPEED
		velocity.z = DIRECTION.z * CURRENT_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, CURRENT_SPEED)
		velocity.z = move_toward(velocity.z, 0, CURRENT_SPEED)

	move_and_slide()

func apply_controller_camera_rotation() -> void:
	controller_input_dir.x = Input.get_action_strength("CAMERA_RIGHT") - Input.get_action_strength("CAMERA_LEFT")
	controller_input_dir.y = Input.get_action_strength("CAMERA_DOWN") - Input.get_action_strength("CAMERA_UP")
	if InputEventJoypadMotion:
		rotate_y(deg_to_rad(-controller_input_dir.x * SENS_CONTROLLER))
		head.rotate_x(deg_to_rad(-controller_input_dir.y * SENS_CONTROLLER))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
