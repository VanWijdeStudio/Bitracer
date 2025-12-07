extends Control

# Add your track scene paths here
var track_paths := [
	"res://scenes/Main/Coralus_Iceway+Car.tscn",
]

var current_index := 0

# Node references
@onready var track_label = $Panel/VBoxContainer/TrackLabel
@onready var btn_prev = $Panel/VBoxContainer/HBoxContainer/BtnPrev
@onready var btn_next = $Panel/VBoxContainer/HBoxContainer/BtnNext
@onready var btn_play = $Panel/VBoxContainer/BtnPlay

func _ready():
	btn_prev.pressed.connect(_on_prev_pressed)
	btn_next.pressed.connect(_on_next_pressed)
	btn_play.pressed.connect(_on_play_pressed)
	
	_update_track_label()

# Update the displayed track name
func _update_track_label():
	var path = track_paths[current_index]
	var file_name = path.get_file().get_basename()
	track_label.text = file_name

# Navigate previous track
func _on_prev_pressed():
	current_index -= 1
	if current_index < 0:
		current_index = track_paths.size() - 1
	_update_track_label()

# Navigate next track
func _on_next_pressed():
	current_index += 1
	if current_index >= track_paths.size():
		current_index = 0
	_update_track_label()

# Load the selected track scene
func _on_play_pressed():
	var path = track_paths[current_index]
	if path != "":
		get_tree().change_scene_to_file(path)

# Get currently selected track path (optional for other scripts)
func get_selected_track_path() -> String:
	return track_paths[current_index]
