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
            "x": gesture_data.get("x", 0.5),
            "y": gesture_data.get("y", 0.5),
            "shoot": gesture_data.get("shoot", False),
            "shield": gesture_data.get("shield", False),
            "special": gesture_data.get("special", False),
            "pause": gesture_data.get("pause", False),
            "dash": gesture_data.get("dash", False),
            "confidence": gesture_data.get("confidence", 0.0),
            "timestamp": int(time.time() * 1000)
        }
        
        payload = json.dumps(packet).encode('utf-8')
        try:
            self.sock.sendto(payload, (self.host, self.port))
        except Exception as e:
            print(f"[UDPSender] Error sending packet: {e}")

    def close(self):
        self.sock.close()
