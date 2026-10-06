class_name SaveManagerClass
extends Node

## Persistent save manager for Gravity: Endless Flight.
## Saves and loads high score, best distance, best combo, and settings.

const SAVE_PATH: String = "user://gravity_save.cfg"

signal records_updated(best_score: int, best_distance: float, best_combo: int)

var best_score: int = 0
var best_distance: float = 0.0
var best_combo: int = 1

var sfx_volume: float = 0.8
var music_volume: float = 0.8
var screen_shake_enabled: bool = true
var fullscreen_enabled: bool = false

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
		sfx_volume = config.get_value("settings", "sfx_volume", 0.8)
		music_volume = config.get_value("settings", "music_volume", 0.8)
		screen_shake_enabled = config.get_value("settings", "screen_shake", true)
		fullscreen_enabled = config.get_value("settings", "fullscreen", false)
	else:
		save_data()

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("records", "best_score", best_score)
	config.set_value("records", "best_distance", best_distance)
	config.set_value("records", "best_combo", best_combo)
	config.set_value("settings", "sfx_volume", sfx_volume)
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "screen_shake", screen_shake_enabled)
	config.set_value("settings", "fullscreen", fullscreen_enabled)
	config.save(SAVE_PATH)

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
