class_name ChronoRigidBody extends RigidBody3D


@onready var physics_recorder: PhysicsRecorder = $PhysicsRecorder

@onready var label: Label3D = $Label3D



@export var reversed: bool = false
			

var time_since_save: float = 0.0
var delta_time: float = 0.0			## used to pass delta data from _physics_process to _integrate_forces()



func _ready() -> void:
	GlobalTime.rewind_all.connect(reverse)
	GlobalTime.resume_all.connect(resume)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	time_since_save += delta
	if not reversed and not freeze:
		physics_recorder.add_time(delta)
		
		var new_keyframe = PhysicsKeyframe.new(transform, linear_velocity, angular_velocity)
		if time_since_save >= 0.1 and new_keyframe.is_different(physics_recorder.current_keyframe):
			physics_recorder.add_keyframe(new_keyframe)
			time_since_save = 0.0
	label.text = str(physics_recorder.current_time).substr(0,5)

func _physics_process(delta: float) -> void:
	delta_time = delta

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Engine.is_editor_hint():
		return
	if reversed:
		var success := physics_recorder.seek(-delta_time)
		var interpolated_keyframe = physics_recorder.current_keyframe
		if interpolated_keyframe:
			state.transform = interpolated_keyframe.transform
			state.linear_velocity = -interpolated_keyframe.velocity
			state.angular_velocity = -interpolated_keyframe.angular_velocity
		if not success:
			resume()
			return
		

	
func reverse() -> void:
	if reversed:
		return
	#print("reversing...")
	reversed = true
	can_sleep = false
	sleeping = false
	custom_integrator = true
	physics_recorder.add_keyframe(PhysicsKeyframe.new(transform, linear_velocity, angular_velocity))
	
func resume() -> void:
	if not reversed:
		return
	#print("resuming...")
	reversed = false
	can_sleep = true
	custom_integrator = false
	var kf = physics_recorder.current_keyframe
	if kf:
		transform = kf.transform
		linear_velocity = kf.velocity
		angular_velocity = kf.angular_velocity
	
