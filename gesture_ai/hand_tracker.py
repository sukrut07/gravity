import cv2
import numpy as np

try:
    import mediapipe as mp
    mp_hands = mp.solutions.hands
    mp_drawing = mp.solutions.drawing_utils
    HAS_MEDIAPIPE = True
except Exception:
    HAS_MEDIAPIPE = False

class HandTracker:
    def __init__(self, max_num_hands=1, min_detection_confidence=0.7, min_tracking_confidence=0.7):
        self.has_mp = HAS_MEDIAPIPE
        if self.has_mp:
            self.hands = mp_hands.Hands(
                static_image_mode=False,
                max_num_hands=max_num_hands,
                min_detection_confidence=min_detection_confidence,
                min_tracking_confidence=min_tracking_confidence
            )
        else:
            self.hands = None

    def process_frame(self, frame):
        """
        Process BGR frame from OpenCV, extract hand landmarks.
        Returns:
            landmarks: list of (x, y, z) normalized dicts/tuples or None
            annotated_frame: frame with visual landmarks drawn
        """
        if not self.has_mp or frame is None:
            return None, frame

        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.hands.process(rgb_frame)
        
        landmarks = None
        if results.multi_hand_landmarks:
            hand_landmarks = results.multi_hand_landmarks[0]
            landmarks = []
            for lm in hand_landmarks.landmark:
                landmarks.append({"x": lm.x, "y": lm.y, "z": lm.z})
            
            # Draw overlay on camera frame
            mp_drawing.draw_landmarks(
                frame,
                hand_landmarks,
                mp_hands.HAND_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(0, 255, 255), thickness=2, circle_radius=3),
                mp_drawing.DrawingSpec(color=(255, 0, 255), thickness=2)
            )

        return landmarks, frame
