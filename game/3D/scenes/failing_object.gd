extends AnimatableBody3D

var reversed: bool = false;


func _ready() -> void:
	$AnimationPlayer.play_section("failingceiling")
	GlobalTime.rewind_all.connect(reverse)
	GlobalTime.resume_all.connect(resume)

func reverse():
	if reversed:
		return
	GlobalTime.num_rewinding += 1
	reversed = true
	$AnimationPlayer.play_section_backwards("failingceiling")

func resume():
	if !reversed:
		return
	GlobalTime.num_rewinding -= 1
	reversed = false
	$AnimationPlayer.play_section("failingceiling")
