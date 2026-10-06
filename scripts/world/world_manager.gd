class_name WorldManager
extends Node2D

## World manager orchestrating endless world scrolling, distance accumulation,
## dynamic spawner lifecycle, and arcade floating score text.

@export var floating_text_scene: PackedScene = preload("res://scenes/FloatingText.tscn")

@onready var spawn_manager: Node2D = get_node_or_null("SpawnManager")

func _ready() -> void:
	ScoreManager.floating_text_requested.connect(_on_floating_text_requested)

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Accumulate distance continuously based on current world speed
	var current_speed = DifficultyManager.world_speed
	# 300 px/sec = 30 meters/sec
	var delta_dist = (current_speed * delta) / 10.0
	GameManager.update_distance(delta_dist, delta)

func _on_floating_text_requested(text: String, world_pos: Vector2, color: Color) -> void:
	if floating_text_scene != null:
		var ft = floating_text_scene.instantiate()
		add_child(ft)
		ft.global_position = world_pos
		if ft.has_method("setup"):
			ft.setup(text, color)
