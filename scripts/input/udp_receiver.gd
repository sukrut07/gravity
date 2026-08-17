class_name UDPReceiver
extends Node

signal packet_received(data: Dictionary)
signal connection_status_changed(connected: bool)

@export var listen_port: int = 4242
@export var listen_address: String = "127.0.0.1"
@export var timeout_seconds: float = 0.5

var udp: PacketPeerUDP = PacketPeerUDP.new()
var is_connected_gesture: bool = false
var last_packet_time: float = 0.0

var latest_packet: Dictionary = {
	"hand_detected": false,
	"x": 0.5,
	"y": 0.5,
	"move_y": 0.0,
	"gesture": "NONE",
	"shoot": false,
	"shield": false,
	"special": false,
	"pause_pressed": false,
	"confidence": 0.0,
	"timestamp": 0
}

func _ready() -> void:
	var err = udp.bind(listen_port, listen_address)
	if err != OK:
		err = udp.bind(listen_port, "*")
	if err != OK:
		push_warning("UDPReceiver: Port %d bind warning - UDP listening on default interface" % listen_port)

func _process(delta: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	var received_any = false
	
	while udp.get_available_packet_count() > 0:
		var pkt = udp.get_packet()
		var pkt_str = pkt.get_string_from_utf8()
		var json = JSON.new()
		var parse_result = json.parse(pkt_str)
		if parse_result == OK and typeof(json.data) == TYPE_DICTIONARY:
			latest_packet = json.data
			last_packet_time = now
			received_any = true
			emit_signal("packet_received", latest_packet)
	
	var currently_active = (now - last_packet_time) <= timeout_seconds and last_packet_time > 0.0
	if currently_active != is_connected_gesture:
		is_connected_gesture = currently_active
		emit_signal("connection_status_changed", is_connected_gesture)
