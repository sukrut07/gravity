class_name Boss
extends Area2D

## Dreadnought Elite Encounter: Optional milestone boss that rewards the player and resumes the endless run.

signal boss_health_changed(current: int, max_hp: int)
signal boss_defeated()

@export var max_health: int = 400
var health: int = 400
var current_phase: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var shoot_timer: float = 0.0
var move_dir: float = 1.0
var entrance_complete: bool = false
var bullet_scene: PackedScene = preload("res://scenes/EnemyBullet.tscn")
var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")
var powerup_scene: PackedScene = preload("res://scenes/Powerup.tscn")

func _ready() -> void:
	add_to_group("boss")
	add_to_group("enemies")
	health = max_health
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_boss_texture()
	
	AudioManager.play_sound("boss_spawn")
	emit_signal("boss_health_changed", health, max_health)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if not entrance_complete:
		position.x = move_toward(position.x, 1060.0, 180.0 * delta)
		if abs(position.x - 1060.0) < 5.0:
			entrance_complete = true
		return
	
	position.y += move_dir * 110.0 * delta
	if position.y <= 130.0:
		move_dir = 1.0
	elif position.y >= 590.0:
		move_dir = -1.0

	shoot_timer += delta
	match current_phase:
		1:
			if shoot_timer >= 1.4:
				shoot_timer = 0.0
				fire_spread_pattern()
		2:
			if shoot_timer >= 1.6:
				shoot_timer = 0.0
				fire_spread_pattern()
				spawn_escort()
		3:
			if shoot_timer >= 0.55:
				shoot_timer = 0.0
				fire_rapid_barrage()

func take_damage(amount: int) -> void:
	health -= amount
	AudioManager.play_sound("boss_hit")
	emit_signal("boss_health_changed", health, max_health)
	
	if sprite != null:
		sprite.modulate = Color(2.0, 1.8, 1.8, 1.0)
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.08)
	
	if health <= int(max_health * 0.66) and current_phase == 1:
		current_phase = 2
	elif health <= int(max_health * 0.33) and current_phase == 2:
		current_phase = 3

	if health <= 0:
		destroy()

func fire_spread_pattern() -> void:
	for angle in [-0.25, 0.0, 0.25]:
		spawn_boss_bullet(angle)

func fire_rapid_barrage() -> void:
	spawn_boss_bullet(randf_range(-0.35, 0.35))

func spawn_boss_bullet(angle: float) -> void:
	if bullet_scene != null:
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = global_position + Vector2(-60.0, 0.0)
		bullet.set("direction", Vector2.LEFT.rotated(angle))
		bullet.rotation = angle

func spawn_escort() -> void:
	var kami_scene = load("res://scenes/EnemyKamikaze.tscn")
	if kami_scene != null:
		var minion = kami_scene.instantiate()
		get_parent().add_child(minion)
		minion.global_position = global_position + Vector2(-70.0, (randf() - 0.5) * 120.0)

func destroy() -> void:
	AudioManager.play_sound("enemy_destroy")
	ScoreManager.add_enemy_kill("boss", global_position)
	GameManager.add_special_energy(50.0)
	
	if powerup_scene != null:
		for p_type in ["shield", "overdrive"]:
			var pup = powerup_scene.instantiate()
			pup.set("powerup_type", p_type)
			get_parent().add_child(pup)
			pup.global_position = global_position + Vector2(-30.0, randf_range(-60.0, 60.0))
			
	if explosion_scene != null:
		for offset in [Vector2.ZERO, Vector2(-40, -30), Vector2(-20, 40), Vector2(30, -20)]:
			var expl = explosion_scene.instantiate()
			get_parent().add_child(expl)
			expl.global_position = global_position + offset
			if expl.has_method("set_explosion_type"):
				expl.set_explosion_type("large")
				
	DifficultyManager.notify_boss_defeated()
	emit_signal("boss_defeated")
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
