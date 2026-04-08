extends Node

signal rewind_all

signal resume_all

##FIXME: 	when spamming rewind-resume, some time is lost. I think this may be due to total_rewind_accumulated
##			growing faster than it should. This is most likely what causes the bug in RewindableAnimationPlayer.
##			I do not know what is wrong. it seems that for every rewind-resume, about 0.03 seconds are lost.

##NOTE:		Try messing around with animation_recorder_test. Press P to start the box animation. it should take 2 seconds.
##			The animation time will vary a little bit normally (I think its just a discrepancy between frame time and event 
##			interrupt time). Spamming rewind-resume (space or RMB) will cause the finish time to be less than 2 seconds
##			before the start time. I am pretty sure the animation is not skipping, so the only other explanation
##			is that the time is being calculated as less than what it should be.

##NOTE:		Summing up delta in _process or _physics_process is said to not be reliable for keeping track of the
##			total time. I am using the system clock instead, but evidently there is a bug so that might also not be
##			reliable.


			
var time_start: float = 0
var total_time_elapsed: float = 0
var last_rewind_time: float = 0
var total_rewind_accumulated: float = 0
var current_rewind_accumulated: float = 0

var reversed: bool = false

var num_rewinding: int = 0:
	set(value):
		num_rewinding = max(value, 0)
		if num_rewinding == 0:
			if reversed:
				resume()
				
				


func _ready() -> void:
	time_start = Time.get_ticks_msec() / 1000.0

func _process(_delta: float) -> void:
	total_time_elapsed = Time.get_ticks_msec() / 1000.0 - time_start
	if reversed:
		current_rewind_accumulated = total_time_elapsed - last_rewind_time
	else:
		current_rewind_accumulated = 0

func get_time() -> float:

	# multiply by 2 in order to go backwards. if we don't, then the time just stops
	return total_time_elapsed - total_rewind_accumulated * 2 - current_rewind_accumulated * 2

	

func rewind() -> void:
	if reversed:
		return

	reversed = true
	last_rewind_time = total_time_elapsed
	rewind_all.emit()
	
func resume() -> void:
	if not reversed:
		return
	
	reversed = false
	total_rewind_accumulated += Time.get_ticks_msec() / 1000.0 - time_start  - last_rewind_time
	current_rewind_accumulated = 0
	resume_all.emit()
	
