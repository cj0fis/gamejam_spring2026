class_name RewindableAnimationPlayer extends AnimationPlayer

##FIXME: while testing, if time is repeatedly reversed and resumed a lot, the recorded stop time of an 
##		 animation is earlier than expected. Time is being lost / not accounted for somewhere.
##		 This is probably some sort of off-by-one error in GlobalTime

##TODO:	 add functionality for animations that are played while time is reversing,
##		 or disallow animations from being played while time is reversing
##		 This might be useful to implement autoplay animations into the queue

##FIXME: there is a bug with animations that are autoplayed. disabling autoplay fixes this

##TODO: implement autoplay in a way that works


class AnimationEvent:
	var name: String
	
	var start_time: float
	var end_time: float = -1
	
	var position: float = 0.0
	
	var has_ended: bool = false

	func _init(_name: String) -> void:
		name = _name
		
	func _to_string() -> String:
		var text = ""
		if has_ended:
			text += "[color=gray]"
		else:
			text += "[color=green]"
		text += "[%.3f]" % start_time
		if has_ended:
			text += " -> [%.3f]" % end_time
		text += "\t" + name
		
		text += "[/color]"
		return text
		
		
		
var timeline: Array[AnimationEvent]
var current_replaying_event: AnimationEvent = null	
var reversed: bool = false
var has_autoplay: bool = false


func add_animation(anim_name: String, start: bool = true, position: float = 0.0) -> void:
	if start:
		var event = AnimationEvent.new(anim_name)
		event.start_time = GlobalTime.get_time()
		event.position = position
		timeline.append(event)
	else:
		var event = timeline[timeline.size()-1] if timeline.size() > 0 else null
		if event and event.name == anim_name:
			event.end_time = GlobalTime.get_time()
			event.position = event.end_time
			event.has_ended = true
			

## called on reverse. will add a stop time to the current animation if it doesn't already have one
func stop_animation(stop_position: float) -> void:
	var event = timeline[timeline.size()-1] if timeline.size() > 0 else null
	if event and not event.has_ended:
		event.end_time = GlobalTime.get_time()
		event.position = stop_position
		event.has_ended = true


func process_reverse() -> void:
	var time = GlobalTime.get_time()
	var event = timeline[timeline.size()-1] if timeline else null
	if event:
		if event.end_time >= time and event != current_replaying_event:
			current_replaying_event = event
			event.has_ended = false
			play_section_backwards(event.name, 0, event.position)
		if event.start_time >= time:	#erase the event from the timeline when it is done replaying
			timeline.erase(event)
			current_replaying_event = null
			process_reverse()					#check again in case another animation was played immediately before
	else:
		resume()


func _process(_delta: float) -> void:
	if reversed:
		process_reverse()

	
func _ready() -> void:
	GlobalTime.rewind_all.connect(reverse)
	GlobalTime.resume_all.connect(resume)
	animation_started.connect(_on_animation_started)
	animation_finished.connect(_on_animation_finished)


func _on_animation_started(anim_name: StringName) -> void:
	if reversed:
		return
	add_animation(anim_name, true, current_animation_position)
	print("Animation started: ", anim_name)
	
func _on_animation_finished(anim_name: StringName) -> void:
	if not reversed:
		add_animation(anim_name, false, current_animation_position)
		print("Animation finished: ", anim_name)
	else:
		pass


func reverse() -> void:
	if reversed:
		return
	GlobalTime.num_rewinding += 1
	if current_animation:
		stop_animation(current_animation_position)
		
	current_replaying_event = null
	reversed = true
	
func resume() -> void:
	if !reversed:
		return
	GlobalTime.num_rewinding -= 1
	reversed = false

	var last_event = timeline[timeline.size()-1] if timeline.size() > 0 else null
	if last_event and not last_event.has_ended:
		play(last_event.name)
	
	if autoplay != "" and (timeline.size() == 0):
		play(autoplay)
