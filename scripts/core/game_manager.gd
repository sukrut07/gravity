class_name GameManagerClass
extends Node

## Master Game Manager for Gravity: Endless Flight.
## Governs game states, distance progression, special ability charge, and session life-cycle.

signal state_changed(old_state: GameState, new_state: GameState)
signal distance_updated(distance_m: float)
signal special_energy_updated(current: float, max_energy: float, is_ready: bool)
signal game_over_processed(stats: Dictionary)

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MENU

var distance_meters: float = 0.0
var shots_fired: int = 0
var shots_hit: int = 0
var powerups_collected: int = 0

var special_energy: float = 0.0
const MAX_SPECIAL_ENERGY: float = 100.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	var old = current_state
	current_state = new_state
	emit_signal("state_changed", old, new_state)
	
	if new_state == GameState.PAUSED:
		get_tree().paused = true
	elif old == GameState.PAUSED:
		get_tree().paused = false

func start_game() -> void:
	distance_meters = 0.0
	shots_fired = 0
	shots_hit = 0
	powerups_collected = 0
	special_energy = 25.0 # Starter boost
	
	ScoreManager.reset_run()
	DifficultyManager.reset_run()
	
	emit_signal("distance_updated", distance_meters)
	emit_signal("special_energy_updated", special_energy, MAX_SPECIAL_ENERGY, is_special_ready())
	change_state(GameState.PLAYING)

func update_distance(delta_meters: float, delta_time: float) -> void:
	if current_state != GameState.PLAYING:
		return
	distance_meters += delta_meters
	emit_signal("distance_updated", distance_meters)
	
	ScoreManager.add_distance_score(delta_meters)
	DifficultyManager.update_difficulty(distance_meters, delta_time)
	
	# Passive slow trickle of special energy while flying
	add_special_energy(delta_meters * 0.012)

func record_shot_fired() -> void:
	shots_fired += 1

func record_shot_hit() -> void:
	shots_hit += 1

func record_powerup_collected() -> void:
	powerups_collected += 1
	ScoreManager.add_powerup_score()
	add_special_energy(15.0)

func add_special_energy(amount: float) -> void:
	var prev_ready = is_special_ready()
	special_energy = clampf(special_energy + amount, 0.0, MAX_SPECIAL_ENERGY)
	var now_ready = is_special_ready()
	emit_signal("special_energy_updated", special_energy, MAX_SPECIAL_ENERGY, now_ready)
	if not prev_ready and now_ready:
		AudioManager.play_sound("shield_activate")

func is_special_ready() -> bool:
	return special_energy >= MAX_SPECIAL_ENERGY

func consume_special() -> bool:
	if is_special_ready():
		special_energy = 0.0
		emit_signal("special_energy_updated", special_energy, MAX_SPECIAL_ENERGY, false)
		AudioManager.play_sound("special_blast")
		return true
	return false

func get_accuracy_percent() -> float:
	if shots_fired <= 0:
		return 100.0
	return clampf((float(shots_hit) / float(shots_fired)) * 100.0, 0.0, 100.0)

func trigger_game_over() -> void:
	if current_state != GameState.PLAYING:
		return
		
	AudioManager.play_sound("game_over")
	var is_new_record = SaveManager.update_records(
		ScoreManager.score,
		distance_meters,
		ScoreManager.max_combo_reached
	)
	
	var stats = {
		"score": ScoreManager.score,
		"distance": distance_meters,
		"enemies_destroyed": ScoreManager.enemies_destroyed,
		"max_combo": ScoreManager.max_combo_reached,
		"accuracy": get_accuracy_percent(),
		"is_new_high_score": is_new_record,
		"best_score": SaveManager.best_score,
		"best_distance": SaveManager.best_distance
	}
	
	emit_signal("game_over_processed", stats)
	change_state(GameState.GAME_OVER)

func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)
	elif current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)
