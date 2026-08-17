class_name InputManager
extends Node

const KeyboardInputScript = preload("res://scripts/input/keyboard_input.gd")
const GestureInputScript = preload("res://scripts/input/gesture_input.gd")
const UDPReceiverScript = preload("res://scripts/input/udp_receiver.gd")

signal input_source_changed(is_gesture: bool)

@export var udp_receiver_path: NodePath = NodePath("../UDPReceiver")

var keyboard_input = KeyboardInputScript.new()
var gesture_input: GestureInput
var udp_receiver: UDPReceiver

var prefer_gesture: bool = true

func _ready() -> void:
	if has_node(udp_receiver_path):
		udp_receiver = get_node(udp_receiver_path)
	else:
		udp_receiver = UDPReceiverScript.new()
		add_child(udp_receiver)
	
	gesture_input = GestureInputScript.new(udp_receiver)
	udp_receiver.connection_status_changed.connect(_on_connection_status_changed)

func _on_connection_status_changed(connected: bool) -> void:
	emit_signal("input_source_changed", connected)

func is_gesture_active() -> bool:
	return prefer_gesture and gesture_input != null and gesture_input.is_available()

func is_hand_detected() -> bool:
	return gesture_input != null and gesture_input.is_hand_detected()

func get_move_vector() -> Vector2:
	# Priority to keyboard if keys are actively pressed (instant manual override)
	var kb_vec = keyboard_input.get_move_vector()
	if kb_vec.length() > 0.0:
		return kb_vec
	
	if is_gesture_active():
		var move_y = gesture_input.get_move_y()
		return Vector2(0.0, move_y)
	
	return Vector2.ZERO

func get_move_y() -> float:
	var kb_vec = keyboard_input.get_move_vector()
	if kb_vec.y != 0.0:
		return kb_vec.y
	if is_gesture_active():
		return gesture_input.get_move_y()
	return 0.0

func is_shooting() -> bool:
	return keyboard_input.is_shooting() or (is_gesture_active() and gesture_input.is_shooting())

func is_shield_active() -> bool:
	return keyboard_input.is_shield_active() or (is_gesture_active() and gesture_input.is_shield_active())

func is_special_triggered() -> bool:
	return keyboard_input.is_special_triggered() or (is_gesture_active() and gesture_input.is_special_triggered())

func is_pause_triggered() -> bool:
	return keyboard_input.is_pause_triggered() or (is_gesture_active() and gesture_input.is_pause_triggered())

func get_gesture_name() -> String:
	if is_gesture_active():
		return gesture_input.get_gesture_name()
	return "KEYBOARD"

func get_confidence() -> float:
	if is_gesture_active():
		return gesture_input.get_confidence()
	return 1.0
