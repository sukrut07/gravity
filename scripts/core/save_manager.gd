class_name SaveManagerClass
extends Node

## Persistent save manager for Gravity: Endless Flight.
## Saves and loads high score, best distance, best combo, and settings.

const SAVE_PATH: String = "user://gravity_save.cfg"

signal records_updated(best_score: int, best_distance: float, best_combo: int)
signal ship_changed(ship_index: int)

var best_score: int = 0
var best_distance: float = 0.0
var best_combo: int = 1

var selected_ship_index: int = 0

var sfx_volume: float = 0.8
var music_volume: float = 0.8
var screen_shake_enabled: bool = true
var fullscreen_enabled: bool = false
var difficulty_preference: int = 1
var touch_controls_preference: String = "OFF"

var is_new_high_score: bool = false
var is_new_high_distance: bool = false

func _ready() -> void:
	load_data()

func load_data() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		best_score = config.get_value("records", "best_score", 0)
		best_distance = config.get_value("records", "best_distance", 0.0)
		best_combo = config.get_value("records", "best_combo", 1)
		selected_ship_index = config.get_value("player", "selected_ship", 0)
		sfx_volume = config.get_value("settings", "sfx_volume", 0.8)
		music_volume = config.get_value("settings", "music_volume", 0.8)
		screen_shake_enabled = config.get_value("settings", "screen_shake", true)
		fullscreen_enabled = config.get_value("settings", "fullscreen", false)
		difficulty_preference = config.get_value("settings", "difficulty", 1)
		touch_controls_preference = config.get_value("settings", "touch_controls", "OFF")
		
		# Propagate loaded settings to managers
		DifficultyManager.set_difficulty(difficulty_preference)
		if InputManager != null:
			InputManager.touch_mode_preference = touch_controls_preference
	else:
		save_data()

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("records", "best_score", best_score)
	config.set_value("records", "best_distance", best_distance)
	config.set_value("records", "best_combo", best_combo)
	config.set_value("player", "selected_ship", selected_ship_index)
	config.set_value("settings", "sfx_volume", sfx_volume)
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "screen_shake", screen_shake_enabled)
	config.set_value("settings", "fullscreen", fullscreen_enabled)
	config.set_value("settings", "difficulty", difficulty_preference)
	config.set_value("settings", "touch_controls", touch_controls_preference)
	config.save(SAVE_PATH)

func set_difficulty_preference(diff_val: int) -> void:
	difficulty_preference = clampi(diff_val, 0, 3)
	save_data()

func set_touch_controls_preference(mode: String) -> void:
	touch_controls_preference = mode
	if InputManager != null:
		InputManager.touch_mode_preference = mode
	save_data()

func set_selected_ship(index: int) -> void:
	if index >= 0 and index < ShipData.get_ship_count():
		selected_ship_index = index
		save_data()
		emit_signal("ship_changed", selected_ship_index)

func get_current_ship_data() -> Dictionary:
	return ShipData.get_ship(selected_ship_index)

func update_records(current_score: int, current_distance: float, current_combo: int) -> bool:
	var record_broken: bool = false
	is_new_high_score = false
	is_new_high_distance = false
	
	if current_score > best_score:
		best_score = current_score
		is_new_high_score = true
		record_broken = true
		
	if current_distance > best_distance:
		best_distance = current_distance
		is_new_high_distance = true
		record_broken = true
		
	if current_combo > best_combo:
		best_combo = current_combo
		record_broken = true
		
	if record_broken:
		save_data()
		emit_signal("records_updated", best_score, best_distance, best_combo)
		
	return is_new_high_score
