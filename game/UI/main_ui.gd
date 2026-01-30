extends Control


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		GlobalTime.rewind_all.emit()
		accept_event()
	if event.is_action_pressed("ui_right"):
		GlobalTime.resume_all.emit()
		accept_event()
