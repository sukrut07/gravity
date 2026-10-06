class_name SpawnManager
extends Node2D

## Procedural endless pattern spawner for Gravity: Endless Flight.
## Generates fair, readable hazard formations, enemy waves, energy trails, and powerups.

@export var asteroid_scene: PackedScene = preload("res://scenes/Asteroid.tscn")
@export var enemy_basic_scene: PackedScene = preload("res://scenes/EnemyBasic.tscn")
@export var enemy_shooter_scene: PackedScene = preload("res://scenes/EnemyShooter.tscn")
@export var enemy_kamikaze_scene: PackedScene = preload("res://scenes/EnemyKamikaze.tscn")
@export var mine_scene: PackedScene = preload("res://scenes/Mine.tscn")
@export var powerup_scene: PackedScene = preload("res://scenes/Powerup.tscn")
@export var energy_scene: PackedScene = preload("res://scenes/EnergyPickup.tscn")
@export var boss_scene: PackedScene = preload("res://scenes/Boss.tscn")

var spawn_timer: float = 0.0
var powerup_timer: float = 0.0
var energy_timer: float = 0.0
var last_pattern_index: int = -1
var elite_active: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const SPAWN_X: float = 1380.0
const MIN_Y: float = 80.0
const MAX_Y: float = 640.0

func _ready() -> void:
	rng.randomize()
	DifficultyManager.event_started.connect(_on_event_started)
	DifficultyManager.event_ended.connect(_on_event_ended)

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Handle Powerup Timer (regular drip every 18-28 seconds)
	powerup_timer += delta
	if powerup_timer >= 22.0:
		powerup_timer = 0.0
		spawn_random_powerup()

	# Handle Energy trails (frequent coin-like trails)
	energy_timer += delta
	if energy_timer >= 5.5:
		energy_timer = 0.0
		spawn_energy_trail()

	# In Elite event, suppress regular wave spawns until boss is destroyed
	if elite_active:
		return

	# Main procedural wave spawning
	spawn_timer += delta
	var current_interval = DifficultyManager.spawn_interval
	if spawn_timer >= current_interval:
		spawn_timer = 0.0
		spawn_next_pattern()

func spawn_next_pattern() -> void:
	var current_event = DifficultyManager.current_event
	
	# Mini-event overrides
	match current_event:
		DifficultyManager.EventType.ASTEROID_STORM:
			pattern_asteroid_corridor()
			return
		DifficultyManager.EventType.DRONE_SWARM:
			pattern_enemy_formation()
			return
		DifficultyManager.EventType.MINE_FIELD:
			pattern_mine_cluster()
			return
		DifficultyManager.EventType.HIGH_VALUE_ZONE:
			pattern_reward_corridor()
			return

	# Standard procedural patterns: pick from 10 fair variations without repeating
	var pattern_index = rng.randi() % 10
	if pattern_index == last_pattern_index:
		pattern_index = (pattern_index + 1) % 10
	last_pattern_index = pattern_index

	match pattern_index:
		0: pattern_single_enemy()
		1: pattern_enemy_pair()
		2: pattern_asteroid_line()
		3: pattern_asteroid_corridor()
		4: pattern_enemy_and_powerup()
		5: pattern_vertical_obstacle_corridor()
		6: pattern_enemy_formation()
		7: pattern_mine_cluster()
		8: pattern_alternating_hazards()
		9: pattern_reward_corridor()

# ----------------- PROCEDURAL PATTERNS -----------------

# Pattern A: Single Interceptor
func pattern_single_enemy() -> void:
	var y = rng.randf_range(MIN_Y, MAX_Y)
	_instantiate_node(enemy_basic_scene, Vector2(SPAWN_X, y))

# Pattern B: Enemy Pair
func pattern_enemy_pair() -> void:
	var gap = rng.randf_range(160.0, 240.0)
	var mid_y = rng.randf_range(MIN_Y + 100, MAX_Y - 100)
	_instantiate_node(enemy_basic_scene, Vector2(SPAWN_X, mid_y - gap * 0.5))
	_instantiate_node(enemy_basic_scene, Vector2(SPAWN_X + 60.0, mid_y + gap * 0.5))

# Pattern C: Asteroid line (staggered with open bypass)
func pattern_asteroid_line() -> void:
	var safe_lane_top = rng.randf() > 0.5
	var base_y = 160.0 if safe_lane_top else 520.0
	for i in range(3):
		var ast = _instantiate_node(asteroid_scene, Vector2(SPAWN_X + (i * 90.0), base_y + (i * 30.0)))
		if ast is Asteroid:
			ast.size_type = "small" if i != 1 else "medium"

# Pattern D: Asteroid corridor (top and bottom with safe flight corridor)
func pattern_asteroid_corridor() -> void:
	var safe_center_y = rng.randf_range(260.0, 460.0)
	var corridor_gap = 240.0 # Guaranteed safe clearance for player
	
	var ast1 = _instantiate_node(asteroid_scene, Vector2(SPAWN_X, safe_center_y - (corridor_gap * 0.5 + 40.0)))
	if ast1 is Asteroid: ast1.size_type = "medium"
	
	var ast2 = _instantiate_node(asteroid_scene, Vector2(SPAWN_X + 30.0, safe_center_y + (corridor_gap * 0.5 + 40.0)))
	if ast2 is Asteroid: ast2.size_type = "medium"

# Pattern E: Enemy + Powerup combo
func pattern_enemy_and_powerup() -> void:
	var y = rng.randf_range(MIN_Y + 80, MAX_Y - 80)
	_instantiate_node(enemy_shooter_scene, Vector2(SPAWN_X, y))
	_instantiate_node(powerup_scene, Vector2(SPAWN_X + 180.0, y + (80.0 if y < 360 else -80.0)))

# Pattern F: Vertical obstacle corridor with clear navigation gate
func pattern_vertical_obstacle_corridor() -> void:
	var gate_y = rng.randf_range(200.0, 500.0)
	# Upper hazard
	var ast_up = _instantiate_node(asteroid_scene, Vector2(SPAWN_X, gate_y - 200.0))
	if ast_up is Asteroid: ast_up.size_type = "large"
	# Lower hazard
	var ast_down = _instantiate_node(asteroid_scene, Vector2(SPAWN_X, gate_y + 200.0))
	if ast_down is Asteroid: ast_down.size_type = "large"
	# Energy cell right through the safe center gate to guide the player!
	_instantiate_node(energy_scene, Vector2(SPAWN_X, gate_y))

# Pattern G: Enemy formation (Interceptor lead with Shooter support)
func pattern_enemy_formation() -> void:
	var base_y = rng.randf_range(220.0, 500.0)
	_instantiate_node(enemy_basic_scene, Vector2(SPAWN_X, base_y))
	_instantiate_node(enemy_kamikaze_scene, Vector2(SPAWN_X + 90.0, base_y - 120.0))
	_instantiate_node(enemy_shooter_scene, Vector2(SPAWN_X + 110.0, base_y + 120.0))

# Pattern H: Space mine cluster with safe corridor
func pattern_mine_cluster() -> void:
	var safe_top = rng.randf() > 0.5
	var start_y = 380.0 if safe_top else 140.0
	for i in range(3):
		_instantiate_node(mine_scene, Vector2(SPAWN_X + (i * 70.0), start_y + (i * 50.0)))

# Pattern I: High/low alternating hazards
func pattern_alternating_hazards() -> void:
	_instantiate_node(asteroid_scene, Vector2(SPAWN_X, MIN_Y + 40.0))
	_instantiate_node(enemy_basic_scene, Vector2(SPAWN_X + 150.0, MAX_Y - 40.0))
	_instantiate_node(asteroid_scene, Vector2(SPAWN_X + 300.0, MIN_Y + 60.0))

# Pattern J: Reward corridor (Curving energy trail with bonus powerup)
func pattern_reward_corridor() -> void:
	var center_y = rng.randf_range(240.0, 480.0)
	for i in range(6):
		var y_offset = sin(i * 0.7) * 70.0
		_instantiate_node(energy_scene, Vector2(SPAWN_X + (i * 60.0), center_y + y_offset))
	# Powerup at tail of reward corridor
	spawn_random_powerup(Vector2(SPAWN_X + 420.0, center_y))

# ----------------- REWARD / SPECIAL SPAWNS -----------------

func spawn_energy_trail() -> void:
	var start_y = rng.randf_range(160.0, 560.0)
	var count = rng.randi_range(4, 7)
	for i in range(count):
		var y_val = start_y + sin(i * 0.6) * 45.0
		_instantiate_node(energy_scene, Vector2(SPAWN_X + (i * 50.0), clampf(y_val, MIN_Y, MAX_Y)))

func spawn_random_powerup(pos: Vector2 = Vector2.ZERO) -> void:
	var types = ["rapid_fire", "triple_shot", "shield", "health", "multiplier", "overdrive"]
	var weights = [25, 25, 18, 14, 10, 8]
	var total_w = 100
	var roll = rng.randi() % total_w
	var chosen = "rapid_fire"
	var accum = 0
	for i in range(types.size()):
		accum += weights[i]
		if roll < accum:
			chosen = types[i]
			break
			
	var spawn_pos = pos if pos != Vector2.ZERO else Vector2(SPAWN_X, rng.randf_range(MIN_Y + 60.0, MAX_Y - 60.0))
	var pup = _instantiate_node(powerup_scene, spawn_pos)
	if pup is Powerup:
		pup.powerup_type = chosen

# ----------------- EVENT HANDLING -----------------

func _on_event_started(event_name: String, _banner: String) -> void:
	if event_name == "ELITE_ENCOUNTER":
		elite_active = true
		_instantiate_node(boss_scene, Vector2(SPAWN_X + 100.0, 360.0))

func _on_event_ended(_event_name: String) -> void:
	elite_active = false

func _instantiate_node(scene: PackedScene, at_pos: Vector2) -> Node:
	if scene == null:
		return null
	var instance = scene.instantiate()
	if instance is Node2D:
		instance.position = at_pos
	add_child(instance)
	return instance
