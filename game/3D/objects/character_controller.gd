class_name CharacterController extends Node

@export var character: Character
@export var pivot: Node3D
@export var camera : Camera3D


func _physics_process(_delta: float) -> void:
	if not character:
		return
		
	var input_dir = Vector3(
		Input.get_axis("move_left","move_right"),
		0,
		Input.get_axis("move_forward","move_backwards")
	)
	character.set_input_direction(input_dir.rotated(Vector3.UP, pivot.rotation.y))
	if Input.is_action_just_pressed("jump"):
		print(character.jump())
	

	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_view(event.relative)


@export_group("Camera")
@export var sensitivity_x : float = 0.005
@export var sensitivity_y : float = 0.005
@export var normal_fov : float = 75.0
@export var run_fov : float = 90.0

enum FOV {NORMAL, RUN}
const CAMERA_BLEND : float = 0.05




func change_fov(setting: FOV) -> void:
	match setting:
		FOV.NORMAL:
			camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
		FOV.RUN:
			camera.fov = lerp(camera.fov, run_fov, CAMERA_BLEND)

func rotate_view(vec: Vector2) -> void:
	pivot.rotation.x -= vec.y * sensitivity_y
	pivot.rotation.x = clampf(pivot.rotation.x, -PI/2, PI/2)
	pivot.rotation.y += -vec.x * sensitivity_x

func set_direction(vec: Vector2) -> void:
	pivot.transform = pivot.transform.looking_at(Vector3(vec.x, pivot.position.y, vec.y))

func get_cam_forward() -> Vector3:
	return -camera.get_global_transform().basis.z 
