class_name EnergyPickup
extends Area2D

## Collectible energy cell that rewards score and charges Special Ability.

@export var speed: float = 340.0
@onready var sprite: Sprite2D = $Sprite2D

var initial_y: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	initial_y = position.y
	time_passed = randf() * 10.0
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	time_passed += delta
	position.x -= speed * delta
	position.y = initial_y + sin(time_passed * 4.0) * 8.0
	
	if sprite != null:
		sprite.rotation += 2.0 * delta
		
	if position.x < -60.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collect()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		collect()

func collect() -> void:
	ScoreManager.add_energy_pickup(global_position)
	GameManager.add_special_energy(6.0)
	AudioManager.play_sound("powerup_pickup")
	queue_free()
