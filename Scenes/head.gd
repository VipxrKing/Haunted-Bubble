extends Node3D

@onready var camera_cast = $RayCast3D
@onready var camera_3d = $Camera3D
var zooming:bool = false

var change:bool = false

func _physics_process(delta):
	if !zooming:
		camera_3d.position = lerp(camera_3d.position,Vector3.ZERO,0.2)
	else:
		if camera_cast.is_colliding():
			camera_3d.position = lerp(camera_3d.position,to_local(camera_cast.get_collision_point())*.75,0.2)
		else:
			camera_3d.position = lerp(camera_3d.position,Vector3(0,0,-5.0),0.2)

func tween_fov(running:bool):
	if change != running:
		change = running
		var tween = create_tween()
		if running:
			tween.tween_property(camera_3d,"fov",90,0.2)
		else:
			tween.tween_property(camera_3d,"fov",75,0.2)
