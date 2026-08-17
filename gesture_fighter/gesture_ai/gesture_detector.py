import math

class GestureDetector:
    def __init__(self):
        pass

    def classify_gesture(self, landmarks):
        """
        Classifies gestures based on 21 3D hand landmarks.
        Returns dictionary containing:
            x, y: normalized hand position (0.0 to 1.0)
            shoot: bool
            shield: bool
            special: bool
            pause: bool
            gesture_name: str
            confidence: float
        """
        if not landmarks or len(landmarks) < 21:
            return {
                "x": 0.5,
                "y": 0.5,
                "shoot": False,
                "shield": False,
                "special": False,
                "pause": False,
                "gesture_name": "NONE",
                "confidence": 0.0
            }

        # Hand position tracking uses Wrist (0) and Index MCP (5) average
        wrist = landmarks[0]
        index_mcp = landmarks[5]
        hand_x = (wrist["x"] + index_mcp["x"]) / 2.0
        hand_y = (wrist["y"] + index_mcp["y"]) / 2.0

        # Finger extension state (Y coordinates inverted: top is 0.0, bottom is 1.0)
        index_ext = landmarks[8]["y"] < landmarks[6]["y"]
        middle_ext = landmarks[12]["y"] < landmarks[10]["y"]
        ring_ext = landmarks[16]["y"] < landmarks[14]["y"]
        pinky_ext = landmarks[20]["y"] < landmarks[18]["y"]
        thumb_ext = abs(landmarks[4]["x"] - landmarks[2]["x"]) > 0.05

        shoot = False
        shield = False
        special = False
        pause = False
        gesture_name = "FLIGHT"
        confidence = 0.90

        # Open Palm -> PAUSE
        if index_ext and middle_ext and ring_ext and pinky_ext:
            pause = True
            gesture_name = "PAUSE (OPEN PALM)"
            confidence = 0.95
        # Closed Fist -> SHIELD
        elif not index_ext and not middle_ext and not ring_ext and not pinky_ext:
            shield = True
            gesture_name = "SHIELD (CLOSED FIST)"
            confidence = 0.95
        # Two Fingers -> SPECIAL
        elif index_ext and middle_ext and not ring_ext and not pinky_ext:
            special = True
            gesture_name = "SPECIAL (VICTORY)"
            confidence = 0.92
        # Index Pointing -> SHOOT
        elif index_ext and not middle_ext and not ring_ext and not pinky_ext:
            shoot = True
            gesture_name = "SHOOT (INDEX POINT)"
            confidence = 0.95

        return {
            "x": round(float(hand_x), 4),
            "y": round(float(hand_y), 4),
            "shoot": shoot,
            "shield": shield,
            "special": special,
            "pause": pause,
            "gesture_name": gesture_name,
            "confidence": confidence
        }
