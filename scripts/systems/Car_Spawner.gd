extends Node2D

# The Marker2D where the car should spawn
@onready var car_spawn: Marker2D = $CarSpawn

# Default car prefab (fallback)
const DEFAULT_CAR := preload("res://scenes/player/Car/Car_Arcade_Physics_with_rpm+gearshifts.tscn")

# Keep a reference to the spawned car (optional, for respawn or later use)
var car: Node2D = null

func _ready():
	_spawn_car()

func _spawn_car():
	# Prevent multiple spawns
	if car:
		return
	
	# Get the selected car from GameGlobals, or use default
	var car_scene: PackedScene
	
	if GameGlobals.selected_car_path != "" and ResourceLoader.exists(GameGlobals.selected_car_path):
		car_scene = load(GameGlobals.selected_car_path)
	else:
		car_scene = DEFAULT_CAR
	
	# Instantiate the car
	car = car_scene.instantiate()
	add_child(car)
	
	# Position and rotate at the spawn marker
	car.global_transform = car_spawn.global_transform
	
	# Make the car's Camera2D current
	if car.has_node("Camera2D"):
		car.get_node("Camera2D").make_current()

func respawn_car():
	"""Optional: Respawn the car at the spawn point"""
	if car:
		car.global_transform = car_spawn.global_transform
		# Reset velocity if the car has a RigidBody2D or CharacterBody2D
		if car is RigidBody2D:
			car.linear_velocity = Vector2.ZERO
			car.angular_velocity = 0.0
		elif car is CharacterBody2D:
			car.velocity = Vector2.ZERO
