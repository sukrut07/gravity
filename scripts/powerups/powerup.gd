class_name Powerup
extends Area2D

## Collectible sci-fi powerup providing combat advantages.

@export var powerup_type: String = "rapid_fire" # rapid_fire, shield, triple_shot, health, multiplier, overdrive
@export var duration: float = 8.0
@export var speed: float = 260.0

@onready var sprite: Sprite2D = $Sprite2D

var initial_y: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	initial_y = position.y
	time_passed = randf() * 10.0
	
	var col = Color(1.0, 0.5, 0.1)
	match powerup_type:
		"rapid_fire": col = Color(1.0, 0.4, 0.1, 1.0)
		"shield": col = Color(0.2, 0.8, 1.0, 1.0)
		"triple_shot": col = Color(0.85, 0.25, 0.95, 1.0)
		"health": col = Color(0.2, 0.95, 0.4, 1.0)
		"multiplier": col = Color(1.0, 0.85, 0.15, 1.0)
		"overdrive": col = Color(1.0, 0.2, 0.35, 1.0)
		
	if sprite != null:
		if sprite.texture == null:
			var icon_tex = load("res://assets/ui/bar_round_gloss_large_square.png")
			if icon_tex != null:
				sprite.texture = icon_tex
			else:
				sprite.texture = ProceduralAssets.create_powerup_texture(col)
		sprite.modulate = col
		
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time_passed += delta
	position.x -= speed * delta
	position.y = initial_y + sin(time_passed * 3.5) * 14.0
	
	if sprite != null:
		var pulse = 1.0 + sin(time_passed * 6.0) * 0.12
		sprite.scale = Vector2(0.9 * pulse, 0.9 * pulse)
	
	if position.x < -80.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("apply_powerup"):
		collect(body)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.has_method("apply_powerup"):
		collect(area)

func collect(target: Node) -> void:
	if target.has_method("apply_powerup"):
		target.apply_powerup(powerup_type, duration)
	AudioManager.play_sound("powerup_pickup")
	GameManager.record_powerup_collected()
	queue_free()
