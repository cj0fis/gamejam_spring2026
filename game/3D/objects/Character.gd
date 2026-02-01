class_name Character extends CharacterBody3D

## Smooth Character Controller with Force/Impulse Support
## Provides realistic physics-based movement for CharacterBody3D

# Movement Parameters
@export_group("Ground Movement")
@export var move_speed: float = 7.0
@export var acceleration: float = 10.0
@export var friction: float = 12.0
@export var max_ground_speed: float = 10.0

@export_group("Air Movement")
@export var air_acceleration: float = 5.0
@export var air_friction: float = 1.0
@export var max_air_speed: float = 8.0
@export var air_control: float = 0.3  # How much control you have in air (0-1)

@export_group("Jumping")
@export var jump_velocity: float = 7.0
@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.15

@export_group("Physics")
@export var gravity: float = 20.0
@export var max_fall_speed: float = 30.0
@export var mass: float = 1.0  # Used for force calculations



# Internal state
var external_velocity: Vector3 = Vector3.ZERO  # Accumulated forces and impulses
var grounded_velocity: Vector3 = Vector3.ZERO  # Ground movement velocity
var air_velocity: Vector3 = Vector3.ZERO       # Air movement velocity
var vertical_velocity: float = 0.0             # Gravity/jump velocity

var was_grounded: bool = false
var grounded: bool = false
var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0

# Input direction (set this from your input system)
var input_direction: Vector3 = Vector3.ZERO


func _ready() -> void:
	floor_max_angle = floor_max_angle
	floor_snap_length = floor_snap_length


func _physics_process(delta: float) -> void:
	# Update grounded state
	was_grounded = grounded
	grounded = is_on_floor()
	
	# Update timers
	update_timers(delta)
	
	# Handle state transitions
	handle_state_transitions()
	
	# Apply gravity
	apply_gravity(delta)
	
	# Apply external forces (decay over time)
	apply_external_forces(delta)
	
	if grounded:
		handle_grounded_movement(delta)
	else:
		handle_air_movement(delta)
	
	
	
	# Combine all velocities
	velocity = grounded_velocity + air_velocity + Vector3(0, vertical_velocity, 0) + external_velocity
	
	# Move the character
	move_and_slide()
	
	# Handle landing impact
	if grounded and not was_grounded:
		on_landed()

## Handle movement when on ground
func handle_grounded_movement(delta: float) -> void:
	var horizontal_input = Vector3(input_direction.x, 0, input_direction.z)
	
	if horizontal_input.length() > 0.01:
		# Accelerate in input direction
		var target_velocity = horizontal_input.normalized() * move_speed
		grounded_velocity = grounded_velocity.lerp(target_velocity, acceleration * delta)
		
		# Clamp to max speed
		if grounded_velocity.length() > max_ground_speed:
			grounded_velocity = grounded_velocity.normalized() * max_ground_speed
	else:
		# Apply friction
		grounded_velocity = grounded_velocity.lerp(Vector3.ZERO, friction * delta)
		


	
	# Reset air velocity when grounded
	air_velocity = Vector3.ZERO

## Handle movement when in the air
func handle_air_movement(delta: float) -> void:
	var horizontal_input = Vector3(input_direction.x, 0, input_direction.z)
	
	if horizontal_input.length() > 0.01:
		# Air control - less responsive than ground movement
		var target_velocity = horizontal_input.normalized() * move_speed
		air_velocity = air_velocity.lerp(target_velocity, air_acceleration * air_control * delta)
		
		# Clamp to max air speed
		if air_velocity.length() > max_air_speed:
			air_velocity = air_velocity.normalized() * max_air_speed
	else:
		# Apply air friction (minimal)
		air_velocity = air_velocity.lerp(Vector3.ZERO, air_friction * delta)
	
	# Transfer grounded velocity to air velocity on takeoff
	if was_grounded and not grounded:
		air_velocity = grounded_velocity
		grounded_velocity = Vector3.ZERO

## Apply gravity to vertical velocity
func apply_gravity(delta: float) -> void:
	if not grounded:
		vertical_velocity -= gravity * delta
		vertical_velocity = max(vertical_velocity, -max_fall_speed)
	else:
		if vertical_velocity <= 0:
			vertical_velocity = -0.5	# Small downward force to keep grounded



## Apply and decay external forces (from apply_force/apply_impulse)
func apply_external_forces(delta: float) -> void:
	# Decay external velocity over time
	external_velocity = external_velocity.lerp(Vector3.ZERO, 5.0 * delta)
	
	# Clear if very small
	if external_velocity.length() < 0.01:
		external_velocity = Vector3.ZERO

## Handle state changes (landing, taking off)
func handle_state_transitions() -> void:
	# Update coyote time (grace period for jumping after leaving ground)
	if grounded:
		coyote_timer = coyote_time
	
	# Reset vertical velocity when landing
	if grounded and not was_grounded and vertical_velocity < 0:
		vertical_velocity = 0.0
		
	if not grounded and was_grounded:
		air_velocity += get_platform_velocity()

## Update internal timers
func update_timers(delta: float) -> void:
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if coyote_timer > 0:
		coyote_timer -= delta

## Called when character lands on ground
func on_landed() -> void:
	pass


# ============================================================================
# PUBLIC API - Force and Impulse Application
# ============================================================================
## Apply a continuous force (like RigidBody3D). Force is applied over time using F = ma
func apply_force(force: Vector3, _position: Vector3 = Vector3.ZERO) -> void:
	external_velocity += (force / mass) * get_physics_process_delta_time()

## Apply a force to the center of mass
func apply_central_force(force: Vector3) -> void:
	apply_force(force)

## Apply an instant impulse (like RigidBody3D). Impulse is applied immediately using I = mv
func apply_impulse(impulse: Vector3, _position: Vector3 = Vector3.ZERO) -> void:
	external_velocity += impulse / mass

## Apply an impulse to the center of mass
func apply_central_impulse(impulse: Vector3) -> void:
	apply_impulse(impulse)

## Makes the character jump. returns true if the character was successful
func jump() -> bool:
	# Check if can jump (grounded or coyote time active)
	if grounded or coyote_timer > 0:
		vertical_velocity = jump_velocity
		coyote_timer = 0.0  # Consume coyote time
		grounded = false
		return true
	else:
		# Buffer the jump input
		jump_buffer_timer = jump_buffer_time
		return false

## Call this when the character becomes grounded to check for buffered jumps. This allows jump inputs slightly before landing to still work 
func check_jump_buffer() -> void:
	if jump_buffer_timer > 0 and grounded:
		jump()
		jump_buffer_timer = 0.0

## Set the movement input direction manually
func set_input_direction(direction: Vector3) -> void:
	input_direction = direction

## Get the character's horizontal velocity
func get_horizontal_velocity() -> Vector3:
	return grounded_velocity + air_velocity + Vector3(external_velocity.x, 0, external_velocity.z)

## Get the character's speed
func get_speed() -> float:
	return velocity.length()

## check if the character is on the ground
func is_grounded() -> bool:
	return grounded

## directly add velocity to the character
func add_velocity(vel: Vector3) -> void:
	external_velocity += vel

## manually set the vertical velocity
func set_vertical_velocity(vel: float) -> void:
	vertical_velocity = vel

## clears all external forces and impulses
func reset_external_velocity() -> void:
	external_velocity = Vector3.ZERO
