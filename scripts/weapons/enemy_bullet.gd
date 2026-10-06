class_name EnemyBullet
extends Area2D

## Projectile fired by Shooter drones and Boss Dreadnought.

@export var speed: float = 520.0
@export var damage: int = 1
@export var direction: Vector2 = Vector2.LEFT

func _ready() -> void:
	add_to_group("enemy_bullets")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	position += direction * speed * delta
	if position.x < -80.0 or position.x > 1400.0 or position.y < -80.0 or position.y > 800.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.has_method("take_damage"):
		area.take_damage()
		queue_free()
