extends CharacterBody2D

@export var max_speed: float = 220.0         # top forward speed (pixels/sec)
@export var reverse_max_speed: float = 100.0 # top reverse speed
@export var accel: float = 800.0             # acceleration
@export var brake_accel: float = 1200.0      # reverse acceleration / braking
@export var friction: float = 600.0          # natural slowdown when not accelerating
@export var turn_speed: float = 3.6          # base turning speed (radians/sec)
@export var lateral_damp: float = 6.0        # how quickly sideways velocity is reduced (drift feel)

func _physics_process(delta: float) -> void:
	# forward direction relative to car rotation
	var forward_dir: Vector2 = Vector2.UP.rotated(rotation)

	# desired forward speed based on input
	var desired_forward_speed: float = 0.0
	if Input.is_action_pressed("ui_up"):
		desired_forward_speed = max_speed
	elif Input.is_action_pressed("ui_down"):
		desired_forward_speed = -reverse_max_speed

	# project current velocity onto forward vector (forward component)
	var forward_speed: float = velocity.dot(forward_dir)

	# accelerate or brake toward desired forward component
	if desired_forward_speed != 0.0:
		if sign(desired_forward_speed) == sign(forward_speed) or forward_speed == 0.0:
			# accelerating in same direction
			forward_speed = move_toward(forward_speed, desired_forward_speed, accel * delta)
		else:
			# braking / reversing direction
			forward_speed = move_toward(forward_speed, desired_forward_speed, brake_accel * delta)
	else:
		# no throttle - apply friction to forward component
		forward_speed = move_toward(forward_speed, 0.0, friction * delta)

	# rebuild velocity from forward component and lateral (sideways) component
	var forward_velocity: Vector2 = forward_dir * forward_speed
	var lateral_dir: Vector2 = forward_dir.orthogonal()
	var lateral_speed: float = velocity.dot(lateral_dir)

	# damp lateral speed to create grip/drift behaviour
	lateral_speed = move_toward(lateral_speed, 0.0, lateral_damp * delta)

	# final velocity combines forward and damped lateral components
	velocity = forward_velocity + lateral_dir * lateral_speed

	# turning: scale rotation speed by how fast you're going
	var speed_factor: float = clamp(abs(forward_speed) / max_speed, 0.0, 1.0)
	var turn_input: float = 0.0
	if Input.is_action_pressed("ui_left"):
		turn_input = -1.0
	elif Input.is_action_pressed("ui_right"):
		turn_input = 1.0

	rotation += turn_input * turn_speed * delta * speed_factor

	# finally move using CharacterBody2D built-in method (no args)
	move_and_slide()
