class_name RewindableAnimationPlayer extends AnimationPlayer


##TODO:
#	currently, reversing time just plays the animation backwards.
#	this is fine if the animation is a one-shot, and it ended as soon as time is reversed.
#
#	The following edge cases need to be addressed:
#	1. account for the time after the animation finished to wait before it is played backwards
#	2. what if the animation looped X times before rewinding? will it be played backwards X times?
#	3. what if the animation player has multiple tracks that are played? (door open and close)
#	-> for 2 and 3, we must keep track of which animations play and when in order to play them all backwards correctly.



@export var track_name: String
var reversed: bool = false

var last_started: float
var last_finished: float
var animation_running: bool

func _ready() -> void:
	GlobalTime.rewind_all.connect(reverse)
	GlobalTime.resume_all.connect(resume)
	animation_started.connect(_start_animation)
	animation_finished.connect(_done_reversing)
	if autoplay == "":
		play(track_name)

func reverse() -> void:
	if reversed:
		return
	GlobalTime.num_rewinding += 1
	reversed = true
	if animation_running:
		play_section_backwards(track_name, 0.0, current_animation_position)
	else:
		var delta_time: float = Time.get_unix_time_from_system() - last_finished
		get_tree().create_timer(delta_time).timeout.connect(func(): play_section_backwards(track_name, 0.0, current_animation_length))

func resume() -> void:
	if !reversed:
		return
	GlobalTime.num_rewinding -= 1
	reversed = false
	if autoplay != "":
		play_section(track_name, current_animation_position)

func _start_animation(_anim_name: StringName) -> void:
	last_started = Time.get_unix_time_from_system()
	animation_running = true;

func _done_reversing(_anim_name: StringName) -> void:
	resume()
	last_finished = Time.get_unix_time_from_system()
	animation_running = false;
