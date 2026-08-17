class_name EnemyBasic
extends Area2D

@export var speed: float = 400.0
@export var health: int = 20

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemies")
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_enemy_basic_texture()
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x -= speed * delta
	# Slight sinusoidal movement
	position.y += sin(position.x * 0.02) * 60.0 * delta
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
