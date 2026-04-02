@tool

extends StaticBody3D
@onready var label_3d: Label3D = $Label3D

@export var text: String:
	set(value):
		text = value
		if label_3d:
			label_3d.text = value
			
@export var speed: float = 1.0


var target_scale = 1.0
var mouse_over = false

signal clicked

func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	
	label_3d.text = text

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			#print("event: ", event, "\tpos: ", event_position)
			clicked.emit()


func _mouse_entered() -> void:
	target_scale = 2
	speed *= 2
	mouse_over = true
	
func _mouse_exited() -> void:
	target_scale = 1
	speed *= 0.5
	mouse_over = false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	label_3d.scale = Vector3.ONE * lerpf(label_3d.scale.x, target_scale, 0.2)
	rotation.y += 1.0 * delta * speed
	rotation.x += 0.2 * delta * speed
	rotation.z += -1.7 * delta * speed
