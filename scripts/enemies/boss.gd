class_name Boss
extends Area2D

signal boss_health_changed(current: int, max_hp: int)
signal boss_defeated()

@export var max_health: int = 500
var health: int = 500
var current_phase: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var shoot_timer: float = 0.0
var move_dir: float = 1.0
var entrance_complete: bool = false

func _ready() -> void:
	add_to_group("boss")
	health = max_health
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_boss_texture()
	
	AudioManager.play_sound("boss_spawn")
	emit_signal("boss_health_changed", health, max_health)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Entrance sequence
	if not entrance_complete:
		position.x = move_toward(position.x, 1050.0, 200.0 * delta)
		if abs(position.x - 1050.0) < 5.0:
			entrance_complete = true
		return
	
	# Hovering vertical movement
	position.y += move_dir * 120.0 * delta
	if position.y <= 120.0 or position.y >= 600.0:
		move_dir *= -1.0

	# Attack Patterns based on Phase
	shoot_timer += delta
	match current_phase:
		1:
			if shoot_timer >= 1.2:
				shoot_timer = 0.0
				fire_spread_pattern()
		2:
			if shoot_timer >= 2.0:
				shoot_timer = 0.0
				spawn_minion()
		3:
			if shoot_timer >= 0.4:
				shoot_timer = 0.0
				fire_rapid_barrage()

func take_damage(amount: int) -> void:
	health -= amount
	AudioManager.play_sound("boss_hit")
	emit_signal("boss_health_changed", health, max_health)
	
	# Phase transitions
	if health <= max_health * 0.66 and current_phase == 1:
		current_phase = 2
	elif health <= max_health * 0.33 and current_phase == 2:
		current_phase = 3

	if health <= 0:
		destroy()

func fire_spread_pattern() -> void:
	for angle in [-0.3, 0.0, 0.3]:
		spawn_boss_bullet(angle)

func fire_rapid_barrage() -> void:
	spawn_boss_bullet((randf() - 0.5) * 0.4)

func spawn_boss_bullet(angle: float) -> void:
	var bullet = Area2D.new()
	bullet.collision_layer = 8
	bullet.collision_mask = 1
	var spr = Sprite2D.new()
	spr.texture = ProceduralAssets.create_powerup_texture(Color(1.0, 0.4, 0.1, 0.9))
	spr.scale = Vector2(0.6, 0.6)
	bullet.add_child(spr)
	
	var shape = CollisionShape2D.new()
	var cs = CircleShape2D.new()
	cs.radius = 10.0
	shape.shape = cs
	bullet.add_child(shape)
	
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	
	var b_script = GDScript.new()
	b_script.source_code = """
	extends Area2D
	var speed = 450.0
	var rot_angle = 0.0
	func _ready(): body_entered.connect(_on_body_entered)
	func _process(delta):
		position += Vector2.LEFT.rotated(rot_angle) * speed * delta
		if position.x < -100: queue_free()
	func _on_body_entered(body):
		if body.has_method('take_damage'): body.take_damage(); queue_free()
	"""
	b_script.reload()
	bullet.set_script(b_script)
	bullet.set("rot_angle", angle)

func spawn_minion() -> void:
	var minion_scene = preload("res://scenes/EnemyKamikaze.tscn")
	var minion = minion_scene.instantiate() as Node2D
	get_parent().add_child(minion)
	minion.global_position = global_position + Vector2(-60, (randf() - 0.5) * 100)

func destroy() -> void:
	AudioManager.play_sound("boss_destroy")
	GameManager.add_score(5000)
	emit_signal("boss_defeated")
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage()
