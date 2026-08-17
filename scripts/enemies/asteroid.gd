class_name Asteroid
extends Area2D

@export var speed: float = 350.0
@export var rotation_speed: float = 2.0
@export var size_type: String = "medium" # small, medium, large
@export var health: int = 20

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shadow: Sprite2D = get_node_or_null("Shadow")

var direction: Vector2 = Vector2.LEFT
var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")

func _ready() -> void:
	add_to_group("obstacles")
	var scale_factor = 0.7 if size_type == "small" else (1.0 if size_type == "medium" else 1.4)
	health = 10 if size_type == "small" else (20 if size_type == "medium" else 40)
	
	if anim_sprite != null:
		anim_sprite.scale = Vector2(scale_factor, scale_factor)
	if shadow != null:
		shadow.scale = Vector2(scale_factor, scale_factor)
		
	var shape = CircleShape2D.new()
	shape.radius = 20.0 * scale_factor
	collision_shape.shape = shape
	
	if anim_sprite == null and sprite != null and sprite.texture == null:
		var size_px = int(48 * scale_factor)
		sprite.texture = ProceduralAssets.create_asteroid_texture(size_px)
	
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	var current_world_speed = speed + GameManager.distance_meters * 0.05
	position += direction * current_world_speed * delta
	
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
	if explosion_scene != null:
		var expl = explosion_scene.instantiate()
		if expl != null:
			get_parent().add_child(expl)
			expl.global_position = global_position
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player or body.has_method("take_damage"):
		body.take_damage()
		destroy()

func _on_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.take_damage()
		destroy()
