class_name EnemyKamikaze
extends Area2D

@export var speed: float = 600.0
@export var health: int = 15

@onready var sprite: Sprite2D = $Sprite2D

var target_y: float = 360.0

func _ready() -> void:
	add_to_group("enemies")
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_enemy_kamikaze_texture()
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_y = players[0].global_position.y
		
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x -= speed * delta
	position.y = move_toward(position.y, target_y, speed * 0.4 * delta)
	if position.x < -100.0:
		queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	AudioManager.play_sound("enemy_hit")
	if health <= 0:
		destroy()

func destroy() -> void:
	AudioManager.play_sound("enemy_destroy")
	GameManager.increment_destroyed()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage()
		destroy()
