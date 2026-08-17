import socket
import json
import time

class UDPSender:
    def __init__(self, host="127.0.0.1", port=4242):
        self.host = host
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def send_gesture_packet(self, gesture_data):
        if not gesture_data:
            return
        
        packet = {
            "timestamp": int(time.time() * 1000),
            "hand_detected": bool(gesture_data.get("hand_detected", False)),
            "x": float(gesture_data.get("x", 0.5)),
            "y": float(gesture_data.get("y", 0.5)),
            "move_y": float(gesture_data.get("move_y", 0.0)),
            "gesture": str(gesture_data.get("gesture", "NONE")),
            "shoot": bool(gesture_data.get("shoot", False)),
            "shield": bool(gesture_data.get("shield", False)),
            "special": bool(gesture_data.get("special", False)),
            "pause_pressed": bool(gesture_data.get("pause_pressed", False)),
            "confidence": float(gesture_data.get("confidence", 0.0))
        }
        
        payload = json.dumps(packet).encode('utf-8')
        try:
            self.sock.sendto(payload, (self.host, self.port))
        except Exception as e:
            print(f"[UDPSender] Error sending UDP packet: {e}")

    def close(self):
        try:
            self.sock.close()
        except Exception:
            pass
