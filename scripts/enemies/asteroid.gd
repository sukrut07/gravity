class_name Asteroid
extends Area2D

## Asteroid hazard with variable sizes, rotation, near-miss bonus, and destruction feedback.

@export var speed: float = 320.0
@export var rotation_speed: float = 1.8
@export var size_type: String = "medium"
@export var health: int = 25

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shadow: Sprite2D = get_node_or_null("Shadow")

var direction: Vector2 = Vector2.LEFT
var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")
var near_miss_checked: bool = false
var rot_dir: float = 1.0

func _ready() -> void:
	add_to_group("obstacles")
	rot_dir = 1.0 if randf() > 0.5 else -1.0
	rotation_speed = randf_range(1.2, 2.5) * rot_dir
	
	var scale_factor = 0.7 if size_type == "small" else (1.0 if size_type == "medium" else 1.5)
	health = 15 if size_type == "small" else (25 if size_type == "medium" else 50)
	
	if anim_sprite != null:
		anim_sprite.scale = Vector2(scale_factor, scale_factor)
	if shadow != null:
		shadow.scale = Vector2(scale_factor, scale_factor)
		
	var shape = CircleShape2D.new()
	shape.radius = 18.0 * scale_factor
	collision_shape.shape = shape
	
	if sprite != null and (anim_sprite == null or not anim_sprite.visible):
		sprite.visible = true
		if sprite.texture == null:
			var size_px = int(54 * scale_factor)
			sprite.texture = ProceduralAssets.create_asteroid_texture(size_px)
	
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	var current_world_speed = (speed + (DifficultyManager.world_speed * 0.25)) * DifficultyManager.enemy_speed_mult
	position += direction * current_world_speed * delta
	rotation += rotation_speed * delta
	
	if not near_miss_checked:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			if global_position.x < player.global_position.x and global_position.x > player.global_position.x - 70.0:
				if abs(global_position.y - player.global_position.y) < (70.0 * collision_shape.shape.get("radius") / 18.0):
					near_miss_checked = true
					ScoreManager.record_near_miss(global_position)
					AudioManager.play_sound("near_miss")

	if position.x < -120.0:
		queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	AudioManager.play_sound("asteroid_hit")
	if health <= 0:
		destroy()

func destroy() -> void:
	AudioManager.play_sound("asteroid_destroy")
	ScoreManager.add_enemy_kill("asteroid", global_position)
	if explosion_scene != null:
		var expl = explosion_scene.instantiate()
		if expl != null:
			get_parent().add_child(expl)
			expl.global_position = global_position
			if size_type == "large" and expl.has_method("set_explosion_type"):
				expl.set_explosion_type("large")
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage()
		destroy()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.has_method("take_damage"):
		area.take_damage()
		destroy()
