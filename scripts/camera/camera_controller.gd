class_name CameraController
extends Camera2D

@export var target_path: NodePath
@export var damping_x: float = 5.0
@export var damping_y: float = 5.0
@export var lookahead_distance: float = 120.0

var target: Node2D
var shake_amount: float = 0.0
var shake_decay: float = 5.0

func _ready() -> void:
	if target_path != null and has_node(target_path):
		target = get_node(target_path) as Node2D

func _process(delta: float) -> void:
	if target == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0]
			
	if target != null:
		var desired_pos = target.global_position + Vector2(lookahead_distance, 0)
		global_position.x = lerp(global_position.x, desired_pos.x, delta * damping_x)
		global_position.y = lerp(global_position.y, desired_pos.y, delta * damping_y)
		
		# Clamp camera position to sensible bounds
		global_position.x = clampf(global_position.x, 640.0, 1000.0)
		global_position.y = clampf(global_position.y, 360.0, 360.0)

	# Handle Screen Shake
	if shake_amount > 0.0:
		shake_amount = move_toward(shake_amount, 0.0, shake_decay * delta * 10.0)
		offset = Vector2(
			(randf() - 0.5) * shake_amount * 12.0,
			(randf() - 0.5) * shake_amount * 12.0
		)
	else:
		offset = Vector2.ZERO

func add_shake(amount: float) -> void:
	shake_amount = min(shake_amount + amount, 1.5)
