class_name Asteroid
extends Area2D

@export var speed: float = 350.0
@export var rotation_speed: float = 2.0
@export var size_type: String = "medium" # small, medium, large
@export var health: int = 20

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction: Vector2 = Vector2.LEFT

func _ready() -> void:
	add_to_group("obstacles")
	var size_px = 32 if size_type == "small" else (48 if size_type == "medium" else 72)
	health = 10 if size_type == "small" else (20 if size_type == "medium" else 40)
	
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_asteroid_texture(size_px)
	
	var shape = CircleShape2D.new()
	shape.radius = size_px * 0.42
	collision_shape.shape = shape
	
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	var current_world_speed = speed + GameManager.distance_meters * 0.05
	position += direction * current_world_speed * delta
	rotation += rotation_speed * delta
	
	if position.x < -100.0:
		queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	AudioManager.play_sound("asteroid_hit")
	if health <= 0:
		destroy()

func destroy() -> void:
	AudioManager.play_sound("asteroid_destroy")
	GameManager.increment_destroyed()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player or body.has_method("take_damage"):
		body.take_damage()
		destroy()

func _on_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.take_damage()
		destroy()
