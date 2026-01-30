class_name PhysicsRecorder extends Node

## the body that is being recorded
@onready var body: PhysicsBody3D = get_parent() if get_parent() is PhysicsBody3D else null

var frames: Array[PhysicsKeyframe] = []
var times: Array[float] = []
var current_time: float = 0.0
var total_time: float = 0.0

var current_keyframe: PhysicsKeyframe = null


## adds a keyframe at current_time. if there are already keyframes after current_time, they will be removed
func add_keyframe(keyframe: PhysicsKeyframe) -> void:
	var insert_pos = times.bsearch(current_time, true)
	times.resize(insert_pos)
	times.append(current_time)
	frames.resize(insert_pos)
	frames.append(keyframe)
	total_time = current_time
	current_keyframe = keyframe
	#print("add frame ", insert_pos, " at time ", str(current_time).substr(0,8), " \t\t ", keyframe)


func add_time(dt: float) -> void:
	total_time += dt
	current_time += dt

## returns true if the seek was successful, returns false if the seek went out of bounds or didnt move
func seek(dt: float) -> bool:
	return seek_to(clamp(current_time + dt, 0, total_time))

func seek_to(time: float) -> bool:
	if frames.is_empty():
		return false
	if time == current_time:
		return false
	current_time = time
		
	var frame_index := times.bsearch(current_time)
	var percent: float
	if frame_index < times.size():
		if frame_index > 0:
			percent = (times[frame_index] - current_time) / (times[frame_index] - times[frame_index - 1])
			current_keyframe = frames[frame_index].interpolate(frames[frame_index-1], percent)
			return true
		else:
			percent = 0
			current_keyframe = frames[0]
			return false
	else:
		current_keyframe = frames[frames.size()-1]
		percent = 1
		return true
	

	
	
	
