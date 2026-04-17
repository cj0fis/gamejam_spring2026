extends Node3D

func _process(_delta) -> void:
	if $Character.position.y < 3.0:
		# reset the level
		$Character.position.x = -21.92
		$Character.position.y = 10.12
		$Character.position.z = 0
		$Character.rotation.y = 90
