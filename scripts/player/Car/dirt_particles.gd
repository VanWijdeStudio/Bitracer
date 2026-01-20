extends CPUParticles2D

# Reference to the parent car
var car: RigidBody2D

func _ready():
	# Get parent car reference
	car = get_parent()
	
	# Configure particle system
	top_level = true  # Particles in world space
	local_coords = false  # Use global coordinates
	
	emitting = false
	amount = 20
	lifetime = 1.2
	speed_scale = 1.0
	explosiveness = 0.1
	randomness = 0.4
	
	# Color - bright blue for debugging (change to dirt color later)
	color = Color(0, 0.5, 1, 1)
	
	# Initial direction (will be updated each frame)
	direction = Vector2(0, 1)
	spread = 40.0
	gravity = Vector2.ZERO
	initial_velocity_min = 150.0
	initial_velocity_max = 300.0
	angular_velocity_min = -360.0
	angular_velocity_max = 360.0
	
	# Damping so particles slow down
	damping_min = 2.0
	damping_max = 4.0
	
	# Scale
	scale_amount_min = 3.0
	scale_amount_max = 6.0
	
	# Fade out gradient
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(0.7, Color(1, 1, 1, 0.6))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	color_ramp = gradient

# Call this from the car script to control emission
func set_emitting_state(should_emit: bool, particle_amount: int = 20):
	emitting = should_emit
	amount = particle_amount

func _process(_delta):
	if !car:
		return
	
	# Update position to follow car (using stored local offset)
	var local_offset = position  # This is the local position set in the editor
	global_position = car.global_position + local_offset.rotated(car.rotation)
	
	# Calculate backward direction in global space
	# car's forward is -transform.y, so backward is +transform.y
	var backward_direction = car.transform.y
	
	# Update particle emission direction to shoot backwards
	direction = backward_direction
	
	# Optional: rotate the emitter visual (though this doesn't affect particles with local_coords=false)
	rotation = car.rotation
