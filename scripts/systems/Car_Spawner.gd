extends Node2D

# The Marker2D where the car should spawn
@onready var car_spawn: Marker2D = $CarSpawn

# Default car prefab
const DEFAULT_CAR := preload("res://scenes/player/Car/Car_Arcade_Physics_with_rpm+gearshifts.tscn")

# Keep a reference to the spawned car (optional, for respawn or later use)
var car: Node2D = null

func _ready():
	_spawn_car()

func _spawn_car():
	# Prevent multiple spawns
	if car:
		return

	# Instantiate the car
	car = DEFAULT_CAR.instantiate()
	add_child(car)

	# Position and rotate at the spawn marker
	car.global_transform = car_spawn.global_transform

	# Make the car's Camera2D current
	if car.has_node("Camera2D"):
		car.get_node("Camera2D").make_current()
