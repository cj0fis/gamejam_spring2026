class_name ConveyerBelt extends StaticBody3D

@export var relative_direction: Vector3 = Vector3.FORWARD
@export var speed: float = 5.0

func _physics_process(delta: float) -> void:
	constant_linear_velocity = global_transform.basis * relative_direction.normalized() * speed
