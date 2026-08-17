class_name LevelManager
extends Node2D

@export var asteroid_scene: PackedScene = preload("res://scenes/Asteroid.tscn")
@export var enemy_basic_scene: PackedScene = preload("res://scenes/EnemyBasic.tscn")
@export var enemy_shooter_scene: PackedScene = preload("res://scenes/EnemyShooter.tscn")
@export var enemy_kamikaze_scene: PackedScene = preload("res://scenes/EnemyKamikaze.tscn")
@export var powerup_scene: PackedScene = preload("res://scenes/Powerup.tscn")

enum LevelSection {
	SECTION_1_TRAINING,
	SECTION_2_COMBAT,
	SECTION_3_POWERUP,
	SECTION_4_ASTEROID_FIELD,
	SECTION_5_INTENSE_COMBAT,
	SECTION_6_FINAL_RUN,
	COMPLETED
}

var current_section: LevelSection = LevelSection.SECTION_1_TRAINING
var spawn_timer: float = 0.0
var section_powerup_spawned: bool = false
var final_run_timer: float = 0.0

func _ready() -> void:
	# Trigger Section 1 Intro Announcement
	emit_section_signal(LevelSection.SECTION_1_TRAINING)

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Accumulate Distance (Speed: 300px/s -> 30m/s)
	var current_world_speed = 320.0
	var delta_dist = (current_world_speed * delta) / 10.0
	GameManager.update_distance(delta_dist)
	
	var dist = GameManager.distance_meters

	# Section Transitions
	if dist < 500.0:
		set_section(LevelSection.SECTION_1_TRAINING)
	elif dist < 1000.0:
		set_section(LevelSection.SECTION_2_COMBAT)
	elif dist < 1600.0:
		set_section(LevelSection.SECTION_3_POWERUP)
	elif dist < 2300.0:
		set_section(LevelSection.SECTION_4_ASTEROID_FIELD)
	elif dist < 3000.0:
		set_section(LevelSection.SECTION_5_INTENSE_COMBAT)
	else:
		set_section(LevelSection.SECTION_6_FINAL_RUN)

	# Handle Current Section Gameplay Spawning
	spawn_timer += delta
	match current_section:
		LevelSection.SECTION_1_TRAINING:
			if spawn_timer >= 3.5:
				spawn_timer = 0.0
				spawn_asteroid("small", randf_range(120.0, 600.0))
				
		LevelSection.SECTION_2_COMBAT:
			if spawn_timer >= 2.2:
				spawn_timer = 0.0
				spawn_basic_enemy(randf_range(100.0, 620.0))
				
		LevelSection.SECTION_3_POWERUP:
			if not section_powerup_spawned:
				section_powerup_spawned = true
				spawn_powerup("rapid_fire", 360.0)
			if spawn_timer >= 2.0:
				spawn_timer = 0.0
				spawn_basic_enemy(randf_range(100.0, 620.0))
				
		LevelSection.SECTION_4_ASTEROID_FIELD:
			if spawn_timer >= 1.4:
				spawn_timer = 0.0
				spawn_asteroid_corridor()
				
		LevelSection.SECTION_5_INTENSE_COMBAT:
			if spawn_timer >= 1.1:
				spawn_timer = 0.0
				spawn_intense_wave()
				
		LevelSection.SECTION_6_FINAL_RUN:
			final_run_timer += delta
			if final_run_timer >= 2.5:
				current_section = LevelSection.COMPLETED
				GameManager.trigger_level_complete()

func set_section(new_sec: LevelSection) -> void:
	if current_section == new_sec:
		return
	current_section = new_sec
	emit_section_signal(new_sec)

func emit_section_signal(sec: LevelSection) -> void:
	var title = ""
	var prompt = ""
	match sec:
		LevelSection.SECTION_1_TRAINING:
			title = "SECTION 1 — FLIGHT TRAINING"
			prompt = "MOVE HAND UP / DOWN TO STEER"
		LevelSection.SECTION_2_COMBAT:
			title = "SECTION 2 — FIRST COMBAT"
			prompt = "EXTEND INDEX FINGER TO FIRE CANNONS"
		LevelSection.SECTION_3_POWERUP:
			title = "SECTION 3 — POWERUP DISCOVERY"
			prompt = "COLLECT POWERUP FOR CANNON OVERDRIVE"
		LevelSection.SECTION_4_ASTEROID_FIELD:
			title = "SECTION 4 — ASTEROID BELT"
			prompt = "WARNING: LETHAL ASTEROIDS — DODGE OR DESTROY"
		LevelSection.SECTION_5_INTENSE_COMBAT:
			title = "SECTION 5 — HEAVY ENEMY BARRAGE"
			prompt = "ALERT: SHOOTER & KAMIKAZE UNITS APPROACHING"
		LevelSection.SECTION_6_FINAL_RUN:
			title = "SECTION 6 — FINAL STRETCH"
			prompt = "CLEAR SKIES IN SIGHT — HOLD THE LINE!"
			
	GameManager.emit_signal("section_changed", title, prompt)

func spawn_asteroid(size: String, y_pos: float) -> void:
	var ast = asteroid_scene.instantiate() as Asteroid
	ast.size_type = size
	add_child(ast)
	ast.position = Vector2(1350.0, y_pos)

func spawn_basic_enemy(y_pos: float) -> void:
	var enemy = enemy_basic_scene.instantiate() as Node2D
	add_child(enemy)
	enemy.position = Vector2(1350.0, y_pos)

func spawn_powerup(type: String, y_pos: float) -> void:
	var pup = powerup_scene.instantiate() as Powerup
	pup.powerup_type = type
	add_child(pup)
	pup.position = Vector2(1350.0, y_pos)

func spawn_asteroid_corridor() -> void:
	# Spawns upper & lower asteroid leaving a safe middle gap
	var gap_y = randf_range(240.0, 480.0)
	spawn_asteroid("medium", gap_y - 180.0)
	spawn_asteroid("medium", gap_y + 180.0)

func spawn_intense_wave() -> void:
	var r = randf()
	if r < 0.4:
		var shooter = enemy_shooter_scene.instantiate() as Node2D
		add_child(shooter)
		shooter.position = Vector2(1350.0, randf_range(150.0, 570.0))
	elif r < 0.7:
		var kami = enemy_kamikaze_scene.instantiate() as Node2D
		add_child(kami)
		kami.position = Vector2(1350.0, randf_range(150.0, 570.0))
	else:
		spawn_asteroid("large", randf_range(150.0, 570.0))
