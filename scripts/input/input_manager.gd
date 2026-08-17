class_name InputManager
extends Node

const KeyboardInputScript = preload("res://scripts/input/keyboard_input.gd")
const GestureInputScript = preload("res://scripts/input/gesture_input.gd")
const UDPReceiverScript = preload("res://scripts/input/udp_receiver.gd")

signal input_source_changed(is_gesture: bool)

@export var udp_receiver_path: NodePath = NodePath("../UDPReceiver")

var keyboard_input = KeyboardInputScript.new()
var gesture_input
var udp_receiver

var prefer_gesture: bool = true

func _ready() -> void:
	if has_node(udp_receiver_path):
		udp_receiver = get_node(udp_receiver_path)
	else:
		udp_receiver = UDPReceiverScript.new()
		add_child(udp_receiver)
	
	gesture_input = GestureInputScript.new(udp_receiver)

func is_gesture_active() -> bool:
	return prefer_gesture and gesture_input.is_available()

func get_move_vector() -> Vector2:
	if is_gesture_active():
		var target_norm = gesture_input.get_target_normalized_position()
		var center_norm = Vector2(0.2, 0.5)
		var diff = target_norm - center_norm
		var dir = Vector2.ZERO
		if abs(diff.y) > 0.08:
			dir.y = sign(diff.y) * clamp(abs(diff.y) * 2.5, 0.0, 1.0)
		if abs(diff.x) > 0.08:
			dir.x = sign(diff.x) * clamp(abs(diff.x) * 2.5, 0.0, 1.0)
		
		var kb_vec = keyboard_input.get_move_vector()
		if kb_vec.length() > 0.0:
			return kb_vec
		return dir
	else:
		return keyboard_input.get_move_vector()

func get_target_screen_position(viewport_size: Vector2) -> Vector2:
	if is_gesture_active():
		var norm = gesture_input.get_target_normalized_position()
		return Vector2(
			clampf(norm.x * viewport_size.x, 60.0, viewport_size.x - 60.0),
			clampf(norm.y * viewport_size.y, 60.0, viewport_size.y - 60.0)
		)
	return Vector2.ZERO

func is_shooting() -> bool:
	return keyboard_input.is_shooting() or gesture_input.is_shooting()

func is_shield_active() -> bool:
	return keyboard_input.is_shield_active() or gesture_input.is_shield_active()

func is_special_triggered() -> bool:
	return keyboard_input.is_special_triggered() or gesture_input.is_special_triggered()

func is_pause_triggered() -> bool:
	return keyboard_input.is_pause_triggered() or gesture_input.is_pause_triggered()
