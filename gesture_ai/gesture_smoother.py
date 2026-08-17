import time

class GestureSmoother:
    def __init__(self, alpha=0.25, debounce_frames=3, timeout_sec=0.2):
        self.alpha = alpha
        self.debounce_frames = debounce_frames
        self.timeout_sec = timeout_sec
        
        self.smooth_x = 0.5
        self.smooth_y = 0.5
        self.smooth_move_y = 0.0

        self.candidate_gesture = "NEUTRAL"
        self.candidate_count = 0
        self.active_gesture = "NEUTRAL"

        self.last_pause_state = False
        self.last_detected_time = 0.0

    def smooth(self, raw_data):
        now = time.time()
        
        # Check if hand detected in current frame
        if not raw_data or not raw_data.get("hand_detected", False):
            # No-hand safety timeout check
            if (now - self.last_detected_time) > self.timeout_sec or self.last_detected_time == 0.0:
                self.smooth_move_y = 0.0
                self.active_gesture = "NONE"
                self.last_pause_state = False
                return {
                    "hand_detected": False,
                    "x": 0.5,
                    "y": 0.5,
                    "move_y": 0.0,
                    "shoot": False,
                    "shield": False,
                    "special": False,
                    "pause_pressed": False,
                    "gesture": "NONE",
                    "confidence": 0.0
                }

        self.last_detected_time = now

        # Exponential moving average (EMA) smoothing for coordinates and movement
        raw_x = raw_data.get("x", 0.5)
        raw_y = raw_data.get("y", 0.5)
        raw_move_y = raw_data.get("move_y", 0.0)

        self.smooth_x = self.alpha * raw_x + (1.0 - self.alpha) * self.smooth_x
        self.smooth_y = self.alpha * raw_y + (1.0 - self.alpha) * self.smooth_y
        self.smooth_move_y = self.alpha * raw_move_y + (1.0 - self.alpha) * self.smooth_move_y

        # Gesture Debouncing (requires 3-5 consecutive stable frames)
        detected_gesture = raw_data.get("gesture", "NEUTRAL")
        if detected_gesture == self.candidate_gesture:
            self.candidate_count += 1
            if self.candidate_count >= self.debounce_frames:
                self.active_gesture = self.candidate_gesture
        else:
            self.candidate_gesture = detected_gesture
            self.candidate_count = 1

        # Determine semantic actions based on active debounced gesture
        shoot = (self.active_gesture == "INDEX")
        shield = (self.active_gesture == "FIST")
        special = (self.active_gesture == "TWO_FINGERS")
        
        # Edge-triggered Pause detection (only triggers once on entry into OPEN_PALM)
        current_open_palm = (self.active_gesture == "OPEN_PALM")
        pause_pressed = current_open_palm and not self.last_pause_state
        self.last_pause_state = current_open_palm

        return {
            "hand_detected": True,
            "x": round(float(self.smooth_x), 4),
            "y": round(float(self.smooth_y), 4),
            "move_y": round(float(self.smooth_move_y), 4),
            "shoot": shoot,
            "shield": shield,
            "special": special,
            "pause_pressed": pause_pressed,
            "gesture": self.active_gesture,
            "confidence": raw_data.get("confidence", 0.9)
        }
