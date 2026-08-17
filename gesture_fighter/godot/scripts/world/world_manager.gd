class_name WorldManager
extends Node2D

@export var asteroid_scene: PackedScene = preload("res://scenes/Asteroid.tscn")
@export var enemy_basic_scene: PackedScene = preload("res://scenes/EnemyBasic.tscn")
@export var enemy_shooter_scene: PackedScene = preload("res://scenes/EnemyShooter.tscn")
@export var enemy_kamikaze_scene: PackedScene = preload("res://scenes/EnemyKamikaze.tscn")
@export var powerup_scene: PackedScene = preload("res://scenes/Powerup.tscn")
@export var boss_scene: PackedScene = preload("res://scenes/Boss.tscn")

var spawn_timer: float = 0.0
var powerup_timer: float = 0.0
var boss_spawned: bool = false

var last_milestone_m: float = 0.0

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Scroll World & Accumulate Distance
	var current_speed = 300.0 + GameManager.distance_meters * 0.08
	var delta_dist = (current_speed * delta) / 10.0 # Convert pixels to meters
	GameManager.update_distance(delta_dist)

	# Distance Milestones
	var current_m = GameManager.distance_meters
	if current_m - last_milestone_m >= 500.0:
		last_milestone_m = current_m - fmod(current_m, 500.0)
		GameManager.emit_signal("milestone_reached", last_milestone_m, "MILESTONE REACHED!")
		spawn_powerup()

	# Check for Boss Spawn at 3000m
	if current_m >= 3000.0 and not boss_spawned:
		boss_spawned = true
		spawn_boss()

	# Obstacle & Enemy Spawner Loop
	if not boss_spawned:
		spawn_timer += delta
		var target_interval = maxf(0.8, 2.5 - (current_m * 0.0005))
		if spawn_timer >= target_interval:
			spawn_timer = 0.0
			spawn_random_wave()

func spawn_random_wave() -> void:
	var roll = randf()
	var spawn_x = 1350.0
	var spawn_y = randf_range(80.0, 640.0)

	if roll < 0.45: # Asteroid
		var ast = asteroid_scene.instantiate() as Asteroid
		ast.size_type = ["small", "medium", "large"][randi() % 3]
		add_child(ast)
		ast.position = Vector2(spawn_x, spawn_y)
	elif roll < 0.70: # Basic Enemy Formation
		for i in range(2):
			var enemy = enemy_basic_scene.instantiate() as Node2D
			add_child(enemy)
			enemy.position = Vector2(spawn_x + (i * 60), clampf(spawn_y + (i * 40 - 20), 80.0, 640.0))
	elif roll < 0.88: # Shooter Drone
		var shooter = enemy_shooter_scene.instantiate() as Node2D
		add_child(shooter)
		shooter.position = Vector2(spawn_x, spawn_y)
	else: # Kamikaze
		var kami = enemy_kamikaze_scene.instantiate() as Node2D
		add_child(kami)
		kami.position = Vector2(spawn_x, spawn_y)

func spawn_powerup() -> void:
	var types = ["rapid_fire", "shield", "triple_shot", "health", "multiplier"]
	var chosen_type = types[randi() % types.size()]
	var pup = powerup_scene.instantiate() as Powerup
	pup.powerup_type = chosen_type
	add_child(pup)
	pup.position = Vector2(1350.0, randf_range(120.0, 600.0))

func spawn_boss() -> void:
	var boss = boss_scene.instantiate() as Node2D
	add_child(boss)
	boss.position = Vector2(1400.0, 360.0)
