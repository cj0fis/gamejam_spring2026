extends Control
@onready var vhs_effect: ColorRect = $"effect panel/VHS effect"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		GlobalTime.rewind_all.emit()
		accept_event()
	if event.is_action_pressed("ui_right"):
		GlobalTime.resume_all.emit()
		accept_event()
		
func _process(delta: float) -> void:
	vhs_effect.visible = (GlobalTime.num_rewinding > 0)
