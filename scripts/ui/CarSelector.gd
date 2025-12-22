extends Control

# Car definitions with categories
const CARS := [
	# GT3 Cars
	{
		"category": "Single seater Custom",
		"name": "Default Car",
		"path": "res://scenes/player/Car/Car_Arcade_Physics_with_rpm+gearshifts.tscn",
		"description": "What can i say? Its the default car"
	},
	{
		"category": "Rally",
		"name": "Rally",
		"path": "res://scenes/player/Car/Car_Arcade_Rally_Physics.tscn",
		"description": "This fucker is quite shit"
	},
]

# Folder to auto-scan for modded cars
const MOD_CAR_FOLDER := "res://mods/Cars/"

var categories := {}  # Dictionary: category_name -> [cars]
var category_names := []  # List of category names in order
var mod_cars := []  # List of modded cars (no subcategories)

var current_selection_level := 0  # 0 = category, 1 = car within category
var current_category_index := 0
var current_car_index := 0
var selected_category := ""

@onready var car_label = $Panel/VBoxContainer/CarLabel
@onready var description_label = $Panel/VBoxContainer/DescriptionLabel
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func _ready():
	_load_cars()
	$Panel/VBoxContainer/HBoxContainer/BtnPrev.pressed.connect(_cycle.bind(-1))
	$Panel/VBoxContainer/HBoxContainer/BtnNext.pressed.connect(_cycle.bind(1))
	$Panel/VBoxContainer/BtnSelect.pressed.connect(_on_select)
	$Panel/VBoxContainer/BtnBack.pressed.connect(_on_back)
	_update_ui()

func _load_cars():
	# Organize official cars by category
	for car in CARS:
		var category = car.get("category", "Uncategorized")
		
		if not categories.has(category):
			categories[category] = []
			category_names.append(category)
		
		categories[category].append(car)
	
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
	
	# Add "Mods" category if modded cars exist
	if mod_cars.size() > 0:
		categories["Mods"] = mod_cars
		category_names.append("Mods")

func _cycle(dir: int):
	if current_selection_level == 0:
		# Cycling through categories
		current_category_index = (current_category_index + dir + category_names.size()) % category_names.size()
		current_car_index = 0  # Reset car index when changing category
	else:
		# Cycling through cars within selected category
		var cars_in_category = categories[selected_category]
		current_car_index = (current_car_index + dir + cars_in_category.size()) % cars_in_category.size()
	
	_update_ui()

func _on_select():
	if current_selection_level == 0:
		# Player selected a category - move to car selection
		selected_category = category_names[current_category_index]
		current_selection_level = 1
		current_car_index = 0
		_update_ui()
	else:
		# Player selected a car - save it and proceed
		var cars_in_category = categories[selected_category]
		var selected_car = cars_in_category[current_car_index]
		
		# Store selected car path in GameGlobals
		GameGlobals.selected_car_path = selected_car["path"]
		
		if sfx_player:
			sfx_player.play()
		
		# Proceed to track selector
		_proceed_to_track_selector()

func _on_back():
	if current_selection_level == 1:
		# Go back to category selection
		current_selection_level = 0
		_update_ui()
	else:
		# Go back to main menu or previous screen
		get_tree().change_scene_to_file("res://scenes/Main/MainMenu.tscn")

func _proceed_to_track_selector():
	# Change to track selector scene
	get_tree().change_scene_to_file("res://scenes/Main/TrackSelector.tscn")

func _update_ui():
	# Update back button visibility
	$Panel/VBoxContainer/BtnBack.visible = true
	
	if current_selection_level == 0:
		# Show category selection
		var category = category_names[current_category_index]
		var car_count = categories[category].size()
		
		car_label.text = category
		description_label.text = str(car_count) + (" car" if car_count == 1 else " cars") + " in this category"
		$Panel/VBoxContainer/BtnSelect.text = "Select Category"
		$Panel/VBoxContainer/Title.text = "SELECT CATEGORY"
	else:
		# Show car selection within category
		var cars_in_category = categories[selected_category]
		var selected_car = cars_in_category[current_car_index]
		
		car_label.text = selected_car["name"]
		description_label.text = selected_car.get("description", "")
		$Panel/VBoxContainer/BtnSelect.text = "Confirm Car"
		$Panel/VBoxContainer/Title.text = "SELECT CAR - " + selected_category

func get_selected_car_path() -> String:
	if current_selection_level == 1 and selected_category != "":
		var cars_in_category = categories[selected_category]
		return cars_in_category[current_car_index]["path"]
	return ""
