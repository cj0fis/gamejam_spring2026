extends AnimatableBody3D

@export var animationName: String
var reversed: bool = false

func _ready() -> void:
	GlobalTime.rewind_all.connect(reverse)
	GlobalTime.resume_all.connect(resume)
	$AnimationPlayer.connect("animation_finished", _done_reversing)
	$AnimationPlayer.play_section(animationName)

func reverse() -> void:
	if reversed:
		return
	GlobalTime.num_rewinding += 1
	reversed = true
	$AnimationPlayer.play_section_backwards(animationName, 0.0, $AnimationPlayer.current_animation_position)

func resume() -> void:
	if !reversed:
		return
	GlobalTime.num_rewinding -= 1
	reversed = false
	$AnimationPlayer.play_section(animationName, $AnimationPlayer.current_animation_position)

func _done_reversing(_anim_name: StringName) -> void:
	resume()
