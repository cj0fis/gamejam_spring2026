extends Control
@onready var vhs_effect: ColorRect = $"GUI panel/VHS effect"
@onready var button_hints: RichTextLabel = $"GUI panel/Button Hints"
@onready var num_rewinding: RichTextLabel = $"GUI panel/num_rewinding"


var mouse_just_pressed: bool = false


func _process(delta: float) -> void:
	vhs_effect.visible = GlobalTime.reversed
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		button_hints.visible = false
		mouse_just_pressed = true
	else:
		mouse_just_pressed = false
	if Input.is_action_just_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		button_hints.visible = true
		
	#if Input.is_action_just_pressed("mouse_right") or Input.is_action_just_pressed("jump"):
	if Input.is_action_just_pressed("mouse_right"):
		if not GlobalTime.reversed:
			GlobalTime.rewind()
		else:
			GlobalTime.resume()
			
	num_rewinding.text = str(GlobalTime.num_rewinding)
