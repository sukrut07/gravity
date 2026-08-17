class_name Powerup
extends Area2D

@export var powerup_type: String = "rapid_fire" # rapid_fire, shield, triple_shot, health, multiplier
@export var duration: float = 8.0
@export var speed: float = 250.0

@onready var sprite: Sprite2D = $Sprite2D

var initial_y: float = 0.0

func _ready() -> void:
	initial_y = position.y
	
	var color = Color(1, 1, 0)
	match powerup_type:
		"rapid_fire": color = Color(1.0, 0.4, 0.1) # Orange
		"shield": color = Color(0.2, 0.7, 1.0) # Cyan
		"triple_shot": color = Color(0.8, 0.2, 0.9) # Purple
		"health": color = Color(0.2, 0.9, 0.3) # Green
		"multiplier": color = Color(1.0, 0.85, 0.1) # Gold
	
	if sprite.texture == null:
		sprite.texture = ProceduralAssets.create_powerup_texture(color)
		
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x -= speed * delta
	position.y = initial_y + sin(position.x * 0.05) * 15.0
	
	if position.x < -100.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.apply_powerup(powerup_type, duration)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.apply_powerup(powerup_type, duration)
		queue_free()
