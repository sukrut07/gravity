class_name DifficultyManagerClass
extends Node

## Manages dynamic progression curves, environment milestones, and mini-events for Gravity: Endless Flight.

signal tier_changed(tier_name: String)
signal milestone_reached(distance_m: float, title: String)
signal event_started(event_name: String, banner_text: String)
signal event_ended(event_name: String)
signal difficulty_changed(new_difficulty: int)

# ---- Player-Selectable Difficulty ----
enum Difficulty {
	EASY,
	NORMAL,
	HARD,
	EXTREME
}

var selected_difficulty: int = Difficulty.NORMAL

const DIFFICULTY_NAMES: Array[String] = ["EASY", "NORMAL", "HARD", "EXTREME"]
const DIFFICULTY_DESCRIPTIONS: Array[String] = [
	"Lower enemy pressure. Longer reaction windows.",
	"Balanced arcade challenge.",
	"More enemies. Faster attacks. Less breathing room.",
	"Maximum enemy pressure. Built for experienced players."
]

# Per-difficulty base multipliers applied on top of progression
const DIFFICULTY_DATA: Array[Dictionary] = [
	# EASY
	{
		"enemy_count_multiplier": 0.65,
		"enemy_speed_multiplier": 0.85,
		"spawn_rate_multiplier": 0.80,
		"hazard_multiplier": 0.75,
		"projectile_multiplier": 0.75,
		"powerup_multiplier": 1.20,
		"base_group_size": 1,
		"max_group_size": 2,
		"max_active_enemies": 5,
	},
	# NORMAL
	{
		"enemy_count_multiplier": 1.0,
		"enemy_speed_multiplier": 1.0,
		"spawn_rate_multiplier": 1.0,
		"hazard_multiplier": 1.0,
		"projectile_multiplier": 1.0,
		"powerup_multiplier": 1.0,
		"base_group_size": 2,
		"max_group_size": 4,
		"max_active_enemies": 8,
	},
	# HARD
	{
		"enemy_count_multiplier": 1.35,
		"enemy_speed_multiplier": 1.15,
		"spawn_rate_multiplier": 1.25,
		"hazard_multiplier": 1.25,
		"projectile_multiplier": 1.20,
		"powerup_multiplier": 0.90,
		"base_group_size": 3,
		"max_group_size": 6,
		"max_active_enemies": 10,
	},
	# EXTREME
	{
		"enemy_count_multiplier": 1.75,
		"enemy_speed_multiplier": 1.30,
		"spawn_rate_multiplier": 1.55,
		"hazard_multiplier": 1.50,
		"projectile_multiplier": 1.45,
		"powerup_multiplier": 0.80,
		"base_group_size": 4,
		"max_group_size": 8,
		"max_active_enemies": 12,
	},
]

# ---- Runtime Progression State ----
enum EventType {
	NONE,
	ASTEROID_STORM,
	DRONE_SWARM,
	MINE_FIELD,
	HIGH_VALUE_ZONE,
	ELITE_ENCOUNTER
}

var current_tier: String = "SCOUT SECTOR"
var current_event: EventType = EventType.NONE
var event_timer: float = 0.0
var next_event_distance: float = 2000.0
var last_milestone: float = 0.0

# Computed runtime parameters (base values scaled by difficulty + progression)
var world_speed: float = 320.0
var spawn_interval: float = 2.6
var enemy_speed_mult: float = 1.0
var hazard_rate: float = 0.35
var obstacle_density_bonus: int = 0

# ---- Difficulty API ----

func set_difficulty(value: int) -> void:
	selected_difficulty = clampi(value, 0, Difficulty.EXTREME)
	emit_signal("difficulty_changed", selected_difficulty)

func get_difficulty() -> int:
	return selected_difficulty

func get_difficulty_name() -> String:
	return DIFFICULTY_NAMES[selected_difficulty]

func get_difficulty_description() -> String:
	return DIFFICULTY_DESCRIPTIONS[selected_difficulty]

func _get_data() -> Dictionary:
	return DIFFICULTY_DATA[selected_difficulty]

func get_enemy_count_multiplier() -> float:
	return _get_data()["enemy_count_multiplier"]

func get_spawn_rate_multiplier() -> float:
	return _get_data()["spawn_rate_multiplier"]

func get_enemy_speed_multiplier() -> float:
	return _get_data()["enemy_speed_multiplier"]

func get_hazard_multiplier() -> float:
	return _get_data()["hazard_multiplier"]

func get_projectile_multiplier() -> float:
	return _get_data()["projectile_multiplier"]

func get_powerup_multiplier() -> float:
	return _get_data()["powerup_multiplier"]

func get_base_group_size() -> int:
	return _get_data()["base_group_size"]

func get_max_group_size() -> int:
	return _get_data()["max_group_size"]

func get_max_active_enemies() -> int:
	return _get_data()["max_active_enemies"]

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F1: set_difficulty(Difficulty.EASY)
			KEY_F2: set_difficulty(Difficulty.NORMAL)
			KEY_F3: set_difficulty(Difficulty.HARD)
			KEY_F4: set_difficulty(Difficulty.EXTREME)

# ---- Run Lifecycle ----

func reset_run() -> void:
	current_tier = "SCOUT SECTOR"
	current_event = EventType.NONE
	event_timer = 0.0
	next_event_distance = 1800.0
	last_milestone = 0.0

	var speed_mult = get_enemy_speed_multiplier()
	world_speed = 320.0 * speed_mult
	spawn_interval = 2.6 / get_spawn_rate_multiplier()
	enemy_speed_mult = speed_mult
	hazard_rate = 0.35 * get_hazard_multiplier()
	obstacle_density_bonus = 0

func update_difficulty(distance_m: float, delta: float) -> void:
	var current_score = ScoreManager.score
	# Endless progression factor driven by BOTH score and distance
	var score_progress = float(current_score) / 4500.0
	var dist_progress = distance_m / 5000.0
	var total_progress = score_progress + dist_progress
	
	# Obstacle density bonus scales endlessly every 2200 pts / 2800 meters
	obstacle_density_bonus = int(current_score / 2200.0) + int(distance_m / 2800.0)
	
	# World flight speed smoothly scales up toward 720 px/s with soft diminishing returns
	var difficulty_speed = 320.0 * get_enemy_speed_multiplier()
	world_speed = difficulty_speed + 400.0 * (1.0 - exp(-total_progress * 0.32))
	
	# Spawn interval decreases smoothly and endlessly based on difficulty and progression
	var diff_rate = get_spawn_rate_multiplier()
	spawn_interval = maxf(0.40, 2.6 / (diff_rate * (1.0 + total_progress * 0.35)))
	
	# Enemy speed multiplier scales with progress and difficulty
	enemy_speed_mult = get_enemy_speed_multiplier() * (1.0 + 0.30 * total_progress)
	
	# Hazard ratio shifts higher as score rises
	var base_hazard = 0.35 * get_hazard_multiplier()
	hazard_rate = minf(0.80, base_hazard + (0.08 * score_progress))
	
	# Check Endless Dynamic Tiers (based on combined score and distance)
	var new_tier = "SCOUT SECTOR"
	var effective_milestone = current_score + int(distance_m * 1.5)
	if effective_milestone >= 45000:
		new_tier = "COSMIC MAELSTROM"
	elif effective_milestone >= 30000:
		new_tier = "ENDLESS ABYSS"
	elif effective_milestone >= 20000:
		new_tier = "OMEGA HORIZON"
	elif effective_milestone >= 14000:
		new_tier = "SINGULARITY CORE"
	elif effective_milestone >= 9000:
		new_tier = "HYPERSPACE VOID"
	elif effective_milestone >= 5500:
		new_tier = "GRAVITY WELL"
	elif effective_milestone >= 3000:
		new_tier = "DEEP NEBULA"
	elif effective_milestone >= 1200:
		new_tier = "OUTER PATROL"
		
	if new_tier != current_tier:
		current_tier = new_tier
		emit_signal("tier_changed", current_tier)
		
	# Check Milestones (every 1000m)
	if distance_m >= last_milestone + 1000.0:
		last_milestone = distance_m - fmod(distance_m, 1000.0)
		emit_signal("milestone_reached", last_milestone, "%d METERS SURVIVED" % int(last_milestone))
		
	# Check Events
	if current_event == EventType.NONE:
		if distance_m >= next_event_distance:
			trigger_random_event(distance_m)
	else:
		if current_event != EventType.ELITE_ENCOUNTER:
			event_timer -= delta
			if event_timer <= 0.0:
				end_event()

func trigger_random_event(current_dist: float) -> void:
	var roll = randf()
	if current_dist >= 3500.0 and roll < 0.25:
		current_event = EventType.ELITE_ENCOUNTER
		event_timer = 999.0 # Remains active until boss defeated
		emit_signal("event_started", "ELITE_ENCOUNTER", "WARNING: CAPITAL DREADNOUGHT APPROACHING!")
	elif roll < 0.45:
		current_event = EventType.ASTEROID_STORM
		event_timer = 14.0
		emit_signal("event_started", "ASTEROID_STORM", "CAUTION: DENSE ASTEROID STORM DETECTED!")
	elif roll < 0.70:
		current_event = EventType.DRONE_SWARM
		event_timer = 13.0
		emit_signal("event_started", "DRONE_SWARM", "ALERT: ENEMY INTERCEPTOR WING INBOUND!")
	elif roll < 0.85:
		current_event = EventType.MINE_FIELD
		event_timer = 14.0
		emit_signal("event_started", "MINE_FIELD", "DANGER: PROXIMITY MINEFIELD AHEAD!")
	else:
		current_event = EventType.HIGH_VALUE_ZONE
		event_timer = 12.0
		emit_signal("event_started", "HIGH_VALUE_ZONE", "BONUS: HIGH VALUE ENERGY CORRIDOR!")

func end_event() -> void:
	var old_event = current_event
	current_event = EventType.NONE
	var ev_name = EventType.keys()[old_event]
	emit_signal("event_ended", ev_name)
	next_event_distance += randf_range(2200.0, 3200.0)

func notify_boss_defeated() -> void:
	if current_event == EventType.ELITE_ENCOUNTER:
		end_event()
