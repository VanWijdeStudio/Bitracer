extends Control

# Car definitions - add more as needed
const CARS := [
	{
		"name": "VanWijde Racing car",
		"path": "res://scenes/player/Car/Car_Arcade_Physics_with_rpm+gearshifts.tscn",
		"description": "Default Car",
	},
	{
		 "name": "Rally test Car",
		"path": "res://scenes/player/Car/Car_Arcade_Rally_Physics.tscn",
		 "description": "This fucker is terrible"
	 },
]

# Folder to auto-scan for modded cars
const MOD_CAR_FOLDER := "res://mods/cars/"

var official_cars := []
var mod_cars := []
var current_mode := ""  # "official" or "mods"
var current_index := 0
var in_mode_select := true

@onready var car_label = $Panel/VBoxContainer/CarLabel
@onready var description_label = $Panel/VBoxContainer/DescriptionLabel
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func _ready():
	_load_cars()
	$Panel/VBoxContainer/HBoxContainer/BtnPrev.pressed.connect(_cycle.bind(-1))
	$Panel/VBoxContainer/HBoxContainer/BtnNext.pressed.connect(_cycle.bind(1))
	$Panel/VBoxContainer/BtnSelect.pressed.connect(_on_select)
	_update_ui()

func _load_cars():
	# Load official cars
	official_cars = CARS.duplicate()
	
	# Auto-scan mods folder for modded cars
	var dir = DirAccess.open(MOD_CAR_FOLDER)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".tscn"):
				var car_path = MOD_CAR_FOLDER + file_name
				var display_name = file_name.replace(".tscn", "").replace("_", " ").replace("+", " ")
				mod_cars.append({
					"name": display_name,
					"path": car_path,
					"description": "Modded car"
				})
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	# Auto-skip mode selection if no mods exist
	if mod_cars.size() == 0:
		current_mode = "official"
		in_mode_select = false

func _get_current_cars() -> Array:
	return official_cars if current_mode == "official" else mod_cars

func _cycle(dir: int):
	if in_mode_select:
		# Cycle between Official and Mods
		current_index = (current_index + dir + 2) % 2
	else:
		# Cycle between cars
		var cars = _get_current_cars()
		if cars.size() == 0:
			return
		current_index = (current_index + dir + cars.size()) % cars.size()
	_update_ui()

func _on_select():
	if in_mode_select:
		# Player selected a mode
		current_mode = "official" if current_index == 0 else "mods"
		in_mode_select = false
		current_index = 0
		_update_ui()
	else:
		# Player selected a car - save it globally and proceed
		var cars = _get_current_cars()
		if cars.size() == 0:
			return
		
		# Store selected car path in a global/autoload
		GameGlobals.selected_car_path = cars[current_index]["path"]
		
		if sfx_player:
			sfx_player.play()
		
		# Proceed to track selector or next screen
		_proceed_to_track_selector()

func _proceed_to_track_selector():
	# Change to track selector scene
	get_tree().change_scene_to_file("res://scenes/Main/TrackSelector.tscn")

func _update_ui():
	if in_mode_select:
		# Show mode selection
		car_label.text = "Official Cars" if current_index == 0 else "Modded Cars"
		description_label.text = "Select car source"
		$Panel/VBoxContainer/BtnSelect.text = "Select"
	else:
		# Show car selection
		var cars = _get_current_cars()
		if cars.size() > 0:
			car_label.text = cars[current_index]["name"]
			description_label.text = cars[current_index].get("description", "")
		else:
			car_label.text = "No cars available"
			description_label.text = ""
		$Panel/VBoxContainer/BtnSelect.text = "Confirm"

func get_selected_car_path() -> String:
	var cars = _get_current_cars()
	return cars[current_index]["path"] if cars.size() > 0 else ""
