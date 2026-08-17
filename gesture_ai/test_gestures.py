import unittest
import socket
import json
import time
from gesture_detector import GestureDetector
from gesture_smoother import GestureSmoother
from udp_sender import UDPSender

class TestGestureAI(unittest.TestCase):
    def setUp(self):
        self.detector = GestureDetector(deadzone_top=0.40, deadzone_bottom=0.60)
        self.smoother = GestureSmoother(alpha=0.3, debounce_frames=3, timeout_sec=0.2)

    def _create_landmarks(self, hand_y=0.5, index_ext=False, middle_ext=False, ring_ext=False, pinky_ext=False):
        # 21 landmarks
        # 0: wrist, 5: index mcp, 9: middle mcp, 17: pinky mcp
        lms = [{"x": 0.5, "y": hand_y, "z": 0.0} for _ in range(21)]
        lms[0] = {"x": 0.5, "y": hand_y + 0.15, "z": 0.0} # wrist below palm
        lms[5] = {"x": 0.45, "y": hand_y, "z": 0.0}
        lms[9] = {"x": 0.50, "y": hand_y, "z": 0.0}
        lms[17] = {"x": 0.55, "y": hand_y, "z": 0.0}

        # Index: 8 tip, 6 PIP
        lms[6] = {"x": 0.45, "y": hand_y - 0.05, "z": 0.0}
        lms[8] = {"x": 0.45, "y": hand_y - 0.15 if index_ext else hand_y, "z": 0.0}

        # Middle: 12 tip, 10 PIP
        lms[10] = {"x": 0.50, "y": hand_y - 0.05, "z": 0.0}
        lms[12] = {"x": 0.50, "y": hand_y - 0.15 if middle_ext else hand_y, "z": 0.0}

        # Ring: 16 tip, 14 PIP
        lms[14] = {"x": 0.53, "y": hand_y - 0.05, "z": 0.0}
        lms[16] = {"x": 0.53, "y": hand_y - 0.15 if ring_ext else hand_y, "z": 0.0}

        # Pinky: 20 tip, 18 PIP
        lms[18] = {"x": 0.56, "y": hand_y - 0.05, "z": 0.0}
        lms[20] = {"x": 0.56, "y": hand_y - 0.15 if pinky_ext else hand_y, "z": 0.0}

        return lms

    def test_deadzone_movement(self):
        # Center (in deadzone 0.40 - 0.60)
        lms_center = self._create_landmarks(hand_y=0.50)
        res_center = self.detector.classify_gesture(lms_center)
        self.assertAlmostEqual(res_center["move_y"], 0.0, places=2)

        # Top zone (UP movement: negative move_y)
        lms_top = self._create_landmarks(hand_y=0.20)
        res_top = self.detector.classify_gesture(lms_top)
        self.assertLess(res_top["move_y"], -0.4)

        # Bottom zone (DOWN movement: positive move_y)
        lms_bot = self._create_landmarks(hand_y=0.80)
        res_bot = self.detector.classify_gesture(lms_bot)
        self.assertGreater(res_bot["move_y"], 0.4)

    def test_index_finger_shooting(self):
        lms = self._create_landmarks(index_ext=True, middle_ext=False, ring_ext=False, pinky_ext=False)
        res = self.detector.classify_gesture(lms)
        self.assertEqual(res["gesture"], "INDEX")
        self.assertTrue(res["shoot"])
        self.assertFalse(res["shield"])

    def test_fist_shield(self):
        lms = self._create_landmarks(index_ext=False, middle_ext=False, ring_ext=False, pinky_ext=False)
        res = self.detector.classify_gesture(lms)
        self.assertEqual(res["gesture"], "FIST")
        self.assertTrue(res["shield"])
        self.assertFalse(res["shoot"])

    def test_two_fingers_special(self):
        lms = self._create_landmarks(index_ext=True, middle_ext=True, ring_ext=False, pinky_ext=False)
        res = self.detector.classify_gesture(lms)
        self.assertEqual(res["gesture"], "TWO_FINGERS")
        self.assertTrue(res["special"])

    def test_open_palm_pause_edge_detection(self):
        lms = self._create_landmarks(index_ext=True, middle_ext=True, ring_ext=True, pinky_ext=True)
        res = self.detector.classify_gesture(lms)
        self.assertEqual(res["gesture"], "OPEN_PALM")
        
        # Debouncing 3 frames into OPEN_PALM
        s1 = self.smoother.smooth(res)
        s2 = self.smoother.smooth(res)
        s3 = self.smoother.smooth(res)
        self.assertTrue(s3["pause_pressed"])
        
        # Frame 4: still open palm, but edge-triggered pause_pressed should now be False
        s4 = self.smoother.smooth(res)
        self.assertFalse(s4["pause_pressed"])

    def test_udp_loopback(self):
        recv_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        recv_sock.bind(("127.0.0.1", 4243))
        recv_sock.settimeout(1.0)

        sender = UDPSender(host="127.0.0.1", port=4243)
        test_payload = {
            "hand_detected": True,
            "x": 0.52,
            "y": 0.35,
            "move_y": -0.42,
            "gesture": "INDEX",
            "shoot": True,
            "shield": False,
            "special": False,
            "pause_pressed": False,
            "confidence": 0.95
        }
        sender.send_gesture_packet(test_payload)
        data, addr = recv_sock.recvfrom(1024)
        parsed = json.loads(data.decode("utf-8"))

        self.assertEqual(parsed["gesture"], "INDEX")
        self.assertTrue(parsed["shoot"])
        self.assertAlmostEqual(parsed["move_y"], -0.42, places=2)
        recv_sock.close()
        sender.close()

if __name__ == "__main__":
    unittest.main()
