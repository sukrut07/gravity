class_name DifficultyManagerClass
extends Node

## Manages dynamic progression curves, environment milestones, and mini-events for Gravity: Endless Flight.

signal tier_changed(tier_name: String)
signal milestone_reached(distance_m: float, title: String)
signal event_started(event_name: String, banner_text: String)
signal event_ended(event_name: String)

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

# Dynamic parameters computed from distance
var world_speed: float = 320.0
var spawn_interval: float = 2.6
var enemy_speed_mult: float = 1.0
var hazard_rate: float = 0.35 # ratio of hazards vs enemies

func reset_run() -> void:
	current_tier = "SCOUT SECTOR"
	current_event = EventType.NONE
	event_timer = 0.0
	next_event_distance = 1800.0
	last_milestone = 0.0
	world_speed = 320.0
	spawn_interval = 2.6
	enemy_speed_mult = 1.0
	hazard_rate = 0.35

func update_difficulty(distance_m: float, delta: float) -> void:
	# Compute smooth curve values
	# World speed: from 320 at 0m up to max 680 at 8000m
	var dist_factor = clampf(distance_m / 8000.0, 0.0, 1.0)
	world_speed = lerpf(320.0, 680.0, sqrt(dist_factor))
	
	# Spawn interval: from 2.6s down to 0.9s
	spawn_interval = maxf(0.85, 2.6 - (1.75 * dist_factor))
	
	# Enemy speed multiplier: 1.0 -> 1.55
	enemy_speed_mult = 1.0 + (0.55 * dist_factor)
	
	# Hazard ratio: 0.35 -> 0.65
	hazard_rate = 0.35 + (0.30 * dist_factor)
	
	# Check Tiers
	var new_tier = "SCOUT SECTOR"
	if distance_m >= 8000.0:
		new_tier = "HYPERSPACE VOID"
	elif distance_m >= 5000.0:
		new_tier = "GRAVITY WELL"
	elif distance_m >= 2500.0:
		new_tier = "DEEP NEBULA"
	elif distance_m >= 1000.0:
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
