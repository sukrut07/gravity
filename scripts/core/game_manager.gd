extends Node

signal state_changed(old_state: GameState, new_state: GameState)
signal score_updated(new_score: int, multiplier: int)
signal distance_updated(distance_m: float)
signal destroyed_count_updated(count: int)
signal player_health_updated(current_health: int, shield_active: bool)
signal milestone_reached(distance_m: float, title: String)
signal section_changed(section_name: String, prompt_text: String)
signal level_completed()

enum GameState {
	BOOT,
	CALIBRATION,
	LEVEL_INTRO,
	READY,
	PLAYING,
	PAUSED,
	GAME_OVER,
	LEVEL_COMPLETE
}

var current_state: GameState = GameState.BOOT

var score: int = 0
var score_multiplier: int = 1
var distance_meters: float = 0.0
var destroyed_count: int = 0
var shots_fired: int = 0
var shots_hit: int = 0
var powerups_collected: int = 0

var gesture_mode_enabled: bool = true
var debug_overlay_visible: bool = false
var view_colliders_enabled: bool = false

func _ready() -> void:
	change_state(GameState.READY)

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
	score = 0
	score_multiplier = 1
	distance_meters = 0.0
	destroyed_count = 0
	shots_fired = 0
	shots_hit = 0
	powerups_collected = 0
	emit_signal("score_updated", score, score_multiplier)
	emit_signal("distance_updated", distance_meters)
	emit_signal("destroyed_count_updated", destroyed_count)
	change_state(GameState.PLAYING)

func add_score(points: int) -> void:
	score += points * score_multiplier
	emit_signal("score_updated", score, score_multiplier)

func increment_destroyed() -> void:
	destroyed_count += 1
	add_score(100)
	emit_signal("destroyed_count_updated", destroyed_count)

func record_shot_fired() -> void:
	shots_fired += 1

func record_shot_hit() -> void:
	shots_hit += 1

func record_powerup_collected() -> void:
	powerups_collected += 1
	add_score(250)

func get_accuracy_percent() -> float:
	if shots_fired <= 0:
		return 100.0
	return clampf((float(shots_hit) / float(shots_fired)) * 100.0, 0.0, 100.0)

func update_distance(delta_dist: float) -> void:
	distance_meters += delta_dist
	emit_signal("distance_updated", distance_meters)

func trigger_game_over() -> void:
	if current_state == GameState.PLAYING:
		AudioManager.play_sound("game_over")
		change_state(GameState.GAME_OVER)

func trigger_level_complete() -> void:
	if current_state == GameState.PLAYING:
		AudioManager.play_sound("boss_destroy")
		emit_signal("level_completed")
		change_state(GameState.LEVEL_COMPLETE)

func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)
	elif current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)
