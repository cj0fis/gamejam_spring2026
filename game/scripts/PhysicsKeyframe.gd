class_name PhysicsKeyframe extends RefCounted

var transform: Transform3D
var velocity: Vector3
var angular_velocity: Vector3

func _init(t: Transform3D, v: Vector3 = Vector3.ZERO, av: Vector3 = Vector3.ZERO) -> void:
	transform = t
	velocity = v
	angular_velocity = av
	
func interpolate(kf: PhysicsKeyframe, amount: float) -> PhysicsKeyframe:
	return PhysicsKeyframe.new(
		transform.interpolate_with(kf.transform, amount),
		velocity.lerp(kf.velocity, amount),
		angular_velocity.slerp(kf.angular_velocity, amount)
	)
	
func is_different(kf: PhysicsKeyframe) -> bool:
	if not kf:			## if the other keyframe is null, they are different
		return true
	if (velocity.length_squared() < 0.0001) != (kf.velocity.length_squared() < 0.001):		## if one of the keyframes has movement and the other doesn't, record it 
		return true
	if (angular_velocity.length_squared() < 0.0001) != (kf.angular_velocity.length_squared() < 0.001):
		return true
	return kf.transform.origin.distance_squared_to(transform.origin) > 0.1 ** 2.0 \
	or     kf.transform.basis.get_rotation_quaternion().angle_to(transform.basis.get_rotation_quaternion()) > PI/12.0 

func _to_string() -> String:
	return "t: " + str(transform.origin) + " \t v: " + str(velocity) + " \t av: " + str(angular_velocity)
