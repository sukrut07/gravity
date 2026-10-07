class_name EnemyShooter
extends Area2D

## Shooter Drone: Telegraphed firing with plasma projectiles and near-miss feedback.

@export var speed: float = 260.0
@export var health: int = 30
@export var shoot_interval: float = 1.8

@onready var sprite: Sprite2D = $Sprite2D

var shoot_timer: float = 0.0
var is_telegraphing: bool = false
var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")
var bullet_scene: PackedScene = preload("res://scenes/EnemyBullet.tscn")
var near_miss_checked: bool = false

func _ready() -> void:
	add_to_group("enemies")
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_enemy_shooter_texture()
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	var current_speed = speed * DifficultyManager.enemy_speed_mult
	position.x -= current_speed * delta
	shoot_timer += delta
	
	var proj_mult = DifficultyManager.get_projectile_multiplier()
	var effective_interval = shoot_interval / proj_mult
	
	if shoot_timer >= (effective_interval - 0.35) and not is_telegraphing:
		is_telegraphing = true
		if sprite != null:
			sprite.modulate = Color(1.8, 0.4, 0.4, 1.0)
			
	if shoot_timer >= effective_interval:
		shoot_timer = 0.0
		is_telegraphing = false
		if sprite != null:
			sprite.modulate = Color.WHITE
		fire_enemy_bullet()
	
	# Near miss check
	if not near_miss_checked:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			if global_position.x < player.global_position.x and global_position.x > player.global_position.x - 70.0:
				if abs(global_position.y - player.global_position.y) < 75.0:
					near_miss_checked = true
					ScoreManager.record_near_miss(global_position)
					AudioManager.play_sound("near_miss")

	if position.x < -100.0:
		queue_free()

func fire_enemy_bullet() -> void:
	if bullet_scene != null and position.x > 100.0:
		var bullet = bullet_scene.instantiate() as Node2D
		get_parent().add_child(bullet)
		bullet.global_position = global_position + Vector2(-28, 0)

func take_damage(amount: int) -> void:
	health -= amount
	AudioManager.play_sound("enemy_hit")
	
	if sprite != null and not is_telegraphing:
		sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		
	if health <= 0:
		destroy()

func destroy() -> void:
	AudioManager.play_sound("enemy_destroy")
	ScoreManager.add_enemy_kill("shooter", global_position)
	GameManager.add_special_energy(12.0)
	if explosion_scene != null:
		var expl = explosion_scene.instantiate()
		if expl != null:
			get_parent().add_child(expl)
			expl.global_position = global_position
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
		destroy()
