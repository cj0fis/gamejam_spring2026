extends Control

@onready var label: RichTextLabel = $RichTextLabel

@onready var player: RewindableAnimationPlayer = $"../test animation/RewindableAnimationPlayer"

func _physics_process(delta: float) -> void:
	var timeline = player.timeline
	label.text = ""
	for event in timeline:
		label.text += str(event) + "\n"
	label.text += "total elapsed:      %.2f\n" % GlobalTime.total_time_elapsed
	label.text += "time + 2*rewind: %.2f\n" % (GlobalTime.get_time() + 2 * GlobalTime.total_rewind_accumulated)
	label.text += "current rewind:  %.2f\n" % GlobalTime.current_rewind_accumulated
	label.text += "total rewind:    %.2f\n" % GlobalTime.total_rewind_accumulated
	label.text += "time:   		     %.2f\n" % GlobalTime.get_time()
	
	label.text += "num_rewinding: %d" % GlobalTime.num_rewinding
