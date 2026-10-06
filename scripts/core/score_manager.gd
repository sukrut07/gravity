class_name ScoreManagerClass
extends Node

## Centralized score and combo manager for Gravity: Endless Flight.
## Tracks score, combo multipliers, near misses, and floating feedback requests.

signal score_changed(current_score: int)
signal combo_changed(multiplier: int, timer_ratio: float)
signal near_miss_recorded(points: int)
signal floating_text_requested(text: String, global_pos: Vector2, color: Color)

var score: int = 0
var combo_multiplier: int = 1
var combo_timer: float = 0.0
const COMBO_MAX_TIME: float = 3.2
var max_combo_reached: int = 1

var enemies_destroyed: int = 0
var collectibles_count: int = 0
var near_miss_count: int = 0

# Base score lookup
const SCORE_ASTEROID: int = 50
const SCORE_INTERCEPTOR: int = 100
const SCORE_SHOOTER: int = 175
const SCORE_KAMIKAZE: int = 250
const SCORE_MINE: int = 80
const SCORE_ELITE: int = 5000
const SCORE_NEAR_MISS: int = 25
const SCORE_ENERGY: int = 20
const SCORE_POWERUP: int = 200

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
		
	if combo_multiplier > 1:
		combo_timer -= delta
		var ratio = clampf(combo_timer / COMBO_MAX_TIME, 0.0, 1.0)
		emit_signal("combo_changed", combo_multiplier, ratio)
		if combo_timer <= 0.0:
			reset_combo()

func reset_run() -> void:
	score = 0
	combo_multiplier = 1
	combo_timer = 0.0
	max_combo_reached = 1
	enemies_destroyed = 0
	collectibles_count = 0
	near_miss_count = 0
	emit_signal("score_changed", score)
	emit_signal("combo_changed", combo_multiplier, 0.0)

func add_enemy_kill(type: String, world_pos: Vector2 = Vector2.ZERO) -> void:
	enemies_destroyed += 1
	var base_score = SCORE_INTERCEPTOR
	match type.to_lower():
		"asteroid": base_score = SCORE_ASTEROID
		"interceptor", "basic": base_score = SCORE_INTERCEPTOR
		"shooter": base_score = SCORE_SHOOTER
		"kamikaze": base_score = SCORE_KAMIKAZE
		"mine": base_score = SCORE_MINE
		"boss", "elite": base_score = SCORE_ELITE
		
	var earned = base_score * combo_multiplier
	score += earned
	
	# Increase combo
	if combo_multiplier < 5:
		combo_multiplier += 1
		if combo_multiplier > max_combo_reached:
			max_combo_reached = combo_multiplier
	combo_timer = COMBO_MAX_TIME
	
	emit_signal("score_changed", score)
	emit_signal("combo_changed", combo_multiplier, 1.0)
	
	if world_pos != Vector2.ZERO:
		var popup_text = "+%d" % earned
		if combo_multiplier > 1:
			popup_text = "+%d (x%d)" % [earned, combo_multiplier]
		emit_signal("floating_text_requested", popup_text, world_pos, Color(1.0, 0.9, 0.3))

func record_near_miss(world_pos: Vector2 = Vector2.ZERO) -> void:
	near_miss_count += 1
	var earned = SCORE_NEAR_MISS * combo_multiplier
	score += earned
	emit_signal("score_changed", score)
	emit_signal("near_miss_recorded", earned)
	
	if world_pos != Vector2.ZERO:
		emit_signal("floating_text_requested", "NEAR MISS +%d" % earned, world_pos, Color(0.2, 0.9, 1.0))

func add_energy_pickup(world_pos: Vector2 = Vector2.ZERO) -> void:
	collectibles_count += 1
	var earned = SCORE_ENERGY * combo_multiplier
	score += earned
	emit_signal("score_changed", score)
	if world_pos != Vector2.ZERO:
		emit_signal("floating_text_requested", "+%d" % earned, world_pos, Color(0.3, 1.0, 0.4))

func add_powerup_score(world_pos: Vector2 = Vector2.ZERO) -> void:
	var earned = SCORE_POWERUP * combo_multiplier
	score += earned
	emit_signal("score_changed", score)
	if world_pos != Vector2.ZERO:
		emit_signal("floating_text_requested", "POWERUP +%d" % earned, world_pos, Color(1.0, 0.5, 1.0))

func add_distance_score(meters_delta: float) -> void:
	# Continuous distance scoring: 1 point per 2 meters
	var pts = int(meters_delta * 0.5)
	if pts > 0:
		score += pts
		emit_signal("score_changed", score)

func reset_combo() -> void:
	if combo_multiplier > 1:
		combo_multiplier = 1
		combo_timer = 0.0
		emit_signal("combo_changed", combo_multiplier, 0.0)
