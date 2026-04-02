extends Node3D

@onready var animation_player: RewindableAnimationPlayer = $RewindableAnimationPlayer


var open: bool = false

## used for animation callback
func set_closed():
	open = false
	
## used for animation callback
func set_open():
	open = true

## just for testing
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		if not open: animation_player.play("door_open")
	elif Input.is_action_just_pressed("ui_left"):
		if open: animation_player.play_backwards("door_open")
		
