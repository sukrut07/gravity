class_name EnemyKamikaze
extends Area2D

## Kamikaze drone: Tracks player, charges with high speed burst, near-miss bonus.

@export var speed: float = 380.0
@export var charge_speed: float = 620.0
@export var health: int = 15

@onready var sprite: Sprite2D = $Sprite2D

var target_y: float = 360.0
var is_charging: bool = false
var charge_delay: float = 0.8
var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")
var near_miss_checked: bool = false

func _ready() -> void:
	add_to_group("enemies")
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_enemy_kamikaze_texture()
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_y = players[0].global_position.y
		
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if not is_charging:
		charge_delay -= delta
		if players.size() > 0:
			target_y = players[0].global_position.y
		position.x -= speed * DifficultyManager.enemy_speed_mult * delta
		position.y = move_toward(position.y, target_y, speed * 0.7 * delta)
		
		if charge_delay <= 0.0:
			is_charging = true
			if sprite != null:
				sprite.modulate = Color(1.8, 0.2, 0.2, 1.0)
	else:
		position.x -= charge_speed * DifficultyManager.enemy_speed_mult * delta
		
	# Near miss check
	if not near_miss_checked and players.size() > 0:
		var player = players[0]
		if global_position.x < player.global_position.x and global_position.x > player.global_position.x - 70.0:
			if abs(global_position.y - player.global_position.y) < 75.0:
				near_miss_checked = true
				ScoreManager.record_near_miss(global_position)
				AudioManager.play_sound("near_miss")

	if position.x < -100.0:
		queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	AudioManager.play_sound("enemy_hit")
	if sprite != null:
		sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(1.8, 0.2, 0.2, 1.0) if is_charging else Color.WHITE, 0.1)
	if health <= 0:
		destroy()

func destroy() -> void:
	AudioManager.play_sound("enemy_destroy")
	ScoreManager.add_enemy_kill("kamikaze", global_position)
	GameManager.add_special_energy(14.0)
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
