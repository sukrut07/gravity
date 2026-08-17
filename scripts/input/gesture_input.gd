class_name GestureInput
extends RefCounted

const UDPReceiverScript = preload("res://scripts/input/udp_receiver.gd")

var udp_receiver

func _init(receiver = null) -> void:
	udp_receiver = receiver

func is_available() -> bool:
	return udp_receiver != null and udp_receiver.is_connected_gesture

func get_target_normalized_position() -> Vector2:
	if not is_available():
		return Vector2(0.2, 0.5)
	var pkt = udp_receiver.latest_packet
	var x = clampf(float(pkt.get("x", 0.5)), 0.0, 1.0)
	var y = clampf(float(pkt.get("y", 0.5)), 0.0, 1.0)
	return Vector2(x, y)

func is_shooting() -> bool:
	if not is_available():
		return false
	return bool(udp_receiver.latest_packet.get("shoot", false))

func is_shield_active() -> bool:
	if not is_available():
		return false
	return bool(udp_receiver.latest_packet.get("shield", false))

func is_special_triggered() -> bool:
	if not is_available():
		return false
	return bool(udp_receiver.latest_packet.get("special", false))

func is_pause_triggered() -> bool:
	if not is_available():
		return false
	return bool(udp_receiver.latest_packet.get("pause", false))
