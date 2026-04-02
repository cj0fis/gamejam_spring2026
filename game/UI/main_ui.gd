extends Control
@onready var vhs_effect: ColorRect = $"GUI panel/VHS effect"
@onready var button_hints: RichTextLabel = $"GUI panel/Button Hints"

#
#func _gui_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.pressed:
			#

var mouse_just_pressed: bool = false

func _process(delta: float) -> void:
	vhs_effect.visible = (GlobalTime.num_rewinding > 0)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		button_hints.visible = false
		mouse_just_pressed = true
	else:
		mouse_just_pressed = false
	if Input.is_action_just_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		button_hints.visible = true
		
	if Input.is_action_just_pressed("mouse_right"):
		if GlobalTime.num_rewinding == 0:
			GlobalTime.rewind_all.emit()
		else:
			GlobalTime.resume_all.emit()
