class_name SpaceMine
extends Area2D

## Lethal drifting space mine. Explodes on contact or when shot.

@export var speed: float = 240.0
@export var health: int = 15

@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")
var near_miss_checked: bool = false
var initial_y: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	add_to_group("obstacles")
	initial_y = position.y
	time_passed = randf() * 10.0
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time_passed += delta
	var current_speed = speed * DifficultyManager.enemy_speed_mult
	position.x -= current_speed * delta
	position.y = initial_y + sin(time_passed * 2.0) * 12.0
	
	if anim_sprite != null:
		anim_sprite.rotation += 1.2 * delta
	elif sprite != null:
		sprite.rotation += 1.2 * delta
		
	# Check near miss with player
	if not near_miss_checked:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			if global_position.x < player.global_position.x and global_position.x > player.global_position.x - 70.0:
				if abs(global_position.y - player.global_position.y) < 85.0:
					near_miss_checked = true
					ScoreManager.record_near_miss(global_position)
					AudioManager.play_sound("near_miss")

	if position.x < -100.0:
		queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	AudioManager.play_sound("enemy_hit")
	if health <= 0:
		destroy()

func destroy() -> void:
	AudioManager.play_sound("enemy_destroy")
	ScoreManager.add_enemy_kill("mine", global_position)
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
