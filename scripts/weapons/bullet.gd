class_name Bullet
extends Area2D

@export var speed: float = 1200.0
@export var damage: int = 10
@export var lifetime: float = 2.0

@onready var sprite: Sprite2D = $Sprite2D

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_bullet_texture()
	
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += direction.rotated(rotation) * speed * delta
	lifetime -= delta
	if lifetime <= 0.0 or position.x > 1400.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		GameManager.record_shot_hit()
		area.take_damage(damage)
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
