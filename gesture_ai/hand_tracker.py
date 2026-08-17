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
    def __init__(self, max_num_hands=1, min_detection_confidence=0.7, min_tracking_confidence=0.6):
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
        Process BGR frame from OpenCV, extract 21 3D hand landmarks.
        Returns:
            landmarks: list of 21 dicts {"x", "y", "z"} or None
            annotated_frame: frame with drawn landmark skeleton
        """
        if not self.has_mp or frame is None or self.hands is None:
            return None, frame

        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        rgb_frame.flags.writeable = False
        results = self.hands.process(rgb_frame)
        rgb_frame.flags.writeable = True
        
        landmarks = None
        if results.multi_hand_landmarks:
            hand_landmarks = results.multi_hand_landmarks[0]
            landmarks = []
            for lm in hand_landmarks.landmark:
                landmarks.append({"x": float(lm.x), "y": float(lm.y), "z": float(lm.z)})
            
            # Draw visual landmarks on camera preview
            mp_drawing.draw_landmarks(
                frame,
                hand_landmarks,
                mp_hands.HAND_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(0, 255, 255), thickness=2, circle_radius=3),
                mp_drawing.DrawingSpec(color=(255, 0, 255), thickness=2)
            )

        return landmarks, frame

    def close(self):
        if self.hands:
            self.hands.close()
