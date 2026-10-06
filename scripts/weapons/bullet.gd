class_name Bullet
extends Area2D

## High-speed Pulse Cannon projectile fired by the player.

@export var speed: float = 1350.0
@export var damage: int = 20
@export var lifetime: float = 1.5

@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	if anim_sprite == null and sprite != null and sprite.texture == null:
		sprite.texture = ProceduralAssets.create_bullet_texture()
		
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += direction.rotated(rotation) * speed * delta
	lifetime -= delta
	if lifetime <= 0.0 or position.x > 1360.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		GameManager.record_shot_hit()
		area.take_damage(damage)
		queue_free()
	elif area.is_in_group("obstacles") or area.is_in_group("enemies"):
		GameManager.record_shot_hit()
		if area.has_method("destroy"):
			area.destroy()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		GameManager.record_shot_hit()
		body.take_damage(damage)
		queue_free()
	elif body.is_in_group("obstacles") or body.is_in_group("enemies"):
		GameManager.record_shot_hit()
		if body.has_method("destroy"):
			body.destroy()
		queue_free()
