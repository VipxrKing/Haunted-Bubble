extends CharacterBody3D
class_name Player

@onready var head = $Head
#Flags3

@onready var ray_cast_3d: RayCast3D = $Head/RayCast3D

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

var lantern:bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var sprinting:bool = false
var sprint_blocked:bool = false
var Stamina:float = 5.0

var LanternBattery:float = 1000.0

var StaminaBar
var StaminaBar2
var LanternBar

var keys:int = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	StaminaBar = Utils.get_ui().find_child("StaminaBar")
	StaminaBar2 = Utils.get_ui().find_child("StaminaBar2")
	LanternBar = Utils.get_ui().find_child("LanternBar")
	
func _input(event) -> void:
	if INPUT:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
			head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
	
		if Input.is_action_just_pressed("FLASHLIGHT"):
			if !Utils.custom_equal_aprox_float(LanternBattery,0.0):
				if lantern: $Head/Lantern/AnimationPlayer.play("OFF")
				else: $Head/Lantern/AnimationPlayer.play("ON")
				lantern = !lantern
		
		if Input.is_action_just_pressed("INTERACT"):
			var ray = ray_cast_3d.get_collider()
			if ray is Interactable:
				ray_cast_3d.get_collider().interact()

func _physics_process(delta) -> void:
	
	StaminaBar.value = remap(Stamina,0,5,0,100)
	StaminaBar2.value = remap(Stamina,0,5,0,100)
	LanternBar.value = remap(LanternBattery,0,1000,0,100)
	
	if lantern:
		if !Utils.custom_equal_aprox_float(LanternBattery,0.0):
				LanternBattery = LanternBattery - 0.1
		else:
			lantern = false
			$Head/Lantern/AnimationPlayer.play("TURN_OFF")
	if !sprinting:
		if !Utils.custom_equal_aprox_float(Stamina,5.0):
			Stamina = lerp(Stamina,5.0,delta)
			Utils.get_ui().tween_stamina_bars(true)
		else:
			sprint_blocked = false
			Utils.get_ui().tween_stamina_bars(false)
	else:
		if !Utils.custom_equal_aprox_float(Stamina,0.0):
			Stamina = lerp(Stamina,0.0,delta)
	
	
	if INPUT:
		apply_controller_camera_rotation()
		
		if Input.is_action_pressed("CROUCH"):
			CURRENT_SPEED = CROUNCHING_SPEED
			head.position.y = lerp(head.position.y,1.8 - CROUCHING_DEPTH,delta*LERP_SPEED)
		else:
			head.position.y = lerp(head.position.y,1.8,delta*LERP_SPEED)
			if Input.is_action_pressed("SPRINT"):
				if !Utils.custom_equal_aprox_float(Stamina,0.0) and !sprint_blocked:
					sprinting = true
					Utils.get_ui().tween_stamina_bars(true)
					CURRENT_SPEED = SPRINTING_SPEED
					if DIRECTION:
						head.tween_fov(true)
					else:
						head.tween_fov(false)
				else:
					sprint_blocked = true
					sprinting = false
					CURRENT_SPEED = WALKING_SPEED
					head.tween_fov(false)
					
			else:
				sprinting = false
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

func add_lantern_battery(quantity:float):
	LanternBattery += quantity
	if LanternBattery > 1000: LanternBattery = 1000

func _on_random_timer_timeout() -> void:
	if LanternBar.value < 20:
		if lantern: $Head/Lantern/AnimationPlayer.play("BLINK")
		if randf() > 0.5:
			await get_tree().create_timer(0.3).timeout
			if lantern: $Head/Lantern/AnimationPlayer.play("BLINK")
		$Head/Lantern/RandomTimer.wait_time = randf_range(1.0,5.0)

func death():
	INPUT = false
	Utils.get_ui().death()
	var tween:Tween = create_tween()
	tween.tween_property(head,"rotation:x",deg_to_rad(0),0.5)
	$Head/Lantern/Idler.stop()
	$Head/AnimationPlayer.play("Death")
	
	
func death_finish():
	if lantern: $Head/Lantern/AnimationPlayer.play("TURN_OFF")
	await get_tree().create_timer(2.5).timeout
	Utils.get_ui().death_finish()
