import cv2
import time

class CalibrationManager:
    def __init__(self):
        self.center_x = 0.5
        self.center_y = 0.5
        self.min_x = 0.1
        self.max_x = 0.9
        self.min_y = 0.1
        self.max_y = 0.9

    def normalize_coords(self, raw_x, raw_y):
        norm_x = (raw_x - self.min_x) / (self.max_x - self.min_x + 1e-5)
        norm_y = (raw_y - self.min_y) / (self.max_y - self.min_y + 1e-5)
        return max(0.0, min(1.0, norm_x)), max(0.0, min(1.0, norm_y))
