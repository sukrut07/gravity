import math

class GestureDetector:
    def __init__(self, deadzone_top=0.40, deadzone_bottom=0.60):
        self.deadzone_top = deadzone_top
        self.deadzone_bottom = deadzone_bottom

    def _dist(self, p1, p2):
        return math.sqrt((p1["x"] - p2["x"])**2 + (p1["y"] - p2["y"])**2)

    def classify_gesture(self, landmarks):
        """
        Classifies gestures based on 21 3D hand landmarks.
        Returns:
            Dictionary with normalized coordinates, move_y (-1.0 to 1.0),
            gesture name, booleans (shoot, shield, special, pause), confidence.
        """
        if not landmarks or len(landmarks) < 21:
            return {
                "hand_detected": False,
                "x": 0.5,
                "y": 0.5,
                "move_y": 0.0,
                "shoot": False,
                "shield": False,
                "special": False,
                "pause": False,
                "gesture": "NONE",
                "confidence": 0.0
            }

        wrist = landmarks[0]
        index_mcp = landmarks[5]
        middle_mcp = landmarks[9]
        pinky_mcp = landmarks[17]

        # Calculate stable palm/hand center
        hand_x = (wrist["x"] + index_mcp["x"] + middle_mcp["x"] + pinky_mcp["x"]) / 4.0
        hand_y = (wrist["y"] + index_mcp["y"] + middle_mcp["y"] + pinky_mcp["y"]) / 4.0

        # Calculate normalized vertical movement with dead zone
        # hand_y < deadzone_top (near top of camera) -> move UP (negative move_y)
        # hand_y > deadzone_bottom (near bottom) -> move DOWN (positive move_y)
        move_y = 0.0
        if hand_y < self.deadzone_top:
            move_y = (hand_y - self.deadzone_top) / max(0.01, self.deadzone_top - 0.05)
            move_y = max(-1.0, min(0.0, move_y))
        elif hand_y > self.deadzone_bottom:
            move_y = (hand_y - self.deadzone_bottom) / max(0.01, 0.95 - self.deadzone_bottom)
            move_y = max(0.0, min(1.0, move_y))

        # Palm scale reference (distance between wrist and middle MCP)
        palm_size = max(0.01, self._dist(wrist, middle_mcp))

        # Finger extension tests using tip vs PIP/MCP distance relative to wrist
        # Landmark indices:
        # Thumb: 4 tip, 3 IP, 2 MCP
        # Index: 8 tip, 7 DIP, 6 PIP, 5 MCP
        # Middle: 12 tip, 11 DIP, 10 PIP, 9 MCP
        # Ring: 16 tip, 15 DIP, 14 PIP, 13 MCP
        # Pinky: 20 tip, 19 DIP, 18 PIP, 17 MCP
        
        index_dist = self._dist(landmarks[8], wrist)
        index_pip_dist = self._dist(landmarks[6], wrist)
        index_ext = index_dist > (index_pip_dist * 1.15) and landmarks[8]["y"] < landmarks[6]["y"]

        middle_dist = self._dist(landmarks[12], wrist)
        middle_pip_dist = self._dist(landmarks[10], wrist)
        middle_ext = middle_dist > (middle_pip_dist * 1.15) and landmarks[12]["y"] < landmarks[10]["y"]

        ring_dist = self._dist(landmarks[16], wrist)
        ring_pip_dist = self._dist(landmarks[14], wrist)
        ring_ext = ring_dist > (ring_pip_dist * 1.15) and landmarks[16]["y"] < landmarks[14]["y"]

        pinky_dist = self._dist(landmarks[20], wrist)
        pinky_pip_dist = self._dist(landmarks[18], wrist)
        pinky_ext = pinky_dist > (pinky_pip_dist * 1.15) and landmarks[20]["y"] < landmarks[18]["y"]

        # Deterministic Gesture Priority Classification
        gesture = "NEUTRAL"
        shoot = False
        shield = False
        special = False
        pause = False
        confidence = 0.92

        # 1. OPEN PALM (all 4 main fingers extended) -> PAUSE
        if index_ext and middle_ext and ring_ext and pinky_ext:
            gesture = "OPEN_PALM"
            pause = True
            confidence = 0.96
        # 2. TWO FINGERS (Index + Middle extended, Ring + Pinky folded) -> SPECIAL
        elif index_ext and middle_ext and not ring_ext and not pinky_ext:
            gesture = "TWO_FINGERS"
            special = True
            confidence = 0.94
        # 3. CLOSED FIST (all 4 main fingers folded) -> SHIELD
        elif not index_ext and not middle_ext and not ring_ext and not pinky_ext:
            gesture = "FIST"
            shield = True
            confidence = 0.95
        # 4. INDEX FINGER (Index extended, Middle + Ring + Pinky folded) -> SHOOT
        elif index_ext and not middle_ext and not ring_ext and not pinky_ext:
            gesture = "INDEX"
            shoot = True
            confidence = 0.96
        else:
            gesture = "NEUTRAL"
            confidence = 0.88

        return {
            "hand_detected": True,
            "x": round(float(hand_x), 4),
            "y": round(float(hand_y), 4),
            "move_y": round(float(move_y), 4),
            "shoot": shoot,
            "shield": shield,
            "special": special,
            "pause": pause,
            "gesture": gesture,
            "confidence": round(float(confidence), 2)
        }
