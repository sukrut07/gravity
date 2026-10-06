class_name CameraController
extends Camera2D

## High-performance 2D arcade camera with lookahead and screen shake.

@export var lookahead_distance: float = 60.0

var target: Node2D
var shake_amount: float = 0.0
var shake_decay: float = 4.0

func _ready() -> void:
	add_to_group("camera")

func _process(delta: float) -> void:
	if target == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0]
			
	if target != null:
		# Keep camera centered at standard 1280x720 center (640, 360) with subtle lookahead
		var desired_x = 640.0 + (target.global_position.x - 200.0) * 0.15
		global_position.x = lerpf(global_position.x, desired_x, delta * 4.0)
		global_position.y = 360.0

	# Handle Screen Shake
	if shake_amount > 0.0 and SaveManager.screen_shake_enabled:
		shake_amount = move_toward(shake_amount, 0.0, shake_decay * delta)
		offset = Vector2(
			(randf() - 0.5) * shake_amount * 10.0,
			(randf() - 0.5) * shake_amount * 10.0
		)
	else:
		offset = Vector2.ZERO

func add_shake(amount: float) -> void:
	if SaveManager.screen_shake_enabled:
		shake_amount = minf(shake_amount + amount, 2.0)

func shake(_duration: float, intensity: float) -> void:
	add_shake(intensity * 0.1)
