class_name GestureInput
extends RefCounted

var udp_receiver: Node

func _init(receiver = null) -> void:
	udp_receiver = receiver

func is_available() -> bool:
	return udp_receiver != null and udp_receiver.is_connected_gesture

func is_hand_detected() -> bool:
	if not is_available():
		return false
	return bool(udp_receiver.latest_packet.get("hand_detected", false))

func get_move_y() -> float:
	if not is_available() or not is_hand_detected():
		return 0.0
	return clampf(float(udp_receiver.latest_packet.get("move_y", 0.0)), -1.0, 1.0)

func get_move_vector() -> Vector2:
	return Vector2(0.0, get_move_y())

func get_target_normalized_position() -> Vector2:
	if not is_available() or not is_hand_detected():
		return Vector2(0.2, 0.5)
	var pkt = udp_receiver.latest_packet
	var x = clampf(float(pkt.get("x", 0.5)), 0.0, 1.0)
	var y = clampf(float(pkt.get("y", 0.5)), 0.0, 1.0)
	return Vector2(x, y)

func is_shooting() -> bool:
	if not is_available() or not is_hand_detected():
		return false
	return bool(udp_receiver.latest_packet.get("shoot", false))

func is_shield_active() -> bool:
	if not is_available() or not is_hand_detected():
		return false
	return bool(udp_receiver.latest_packet.get("shield", false))

func is_special_triggered() -> bool:
	if not is_available() or not is_hand_detected():
		return false
	return bool(udp_receiver.latest_packet.get("special", false))

func is_pause_triggered() -> bool:
	if not is_available() or not is_hand_detected():
		return false
	return bool(udp_receiver.latest_packet.get("pause_pressed", false))

func get_gesture_name() -> String:
	if not is_available() or not is_hand_detected():
		return "NONE"
	return str(udp_receiver.latest_packet.get("gesture", "NONE"))

func get_confidence() -> float:
	if not is_available() or not is_hand_detected():
		return 0.0
	return float(udp_receiver.latest_packet.get("confidence", 0.0))
