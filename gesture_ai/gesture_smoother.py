class GestureSmoother:
    def __init__(self, alpha=0.35, deadzone=0.015):
        self.alpha = alpha
        self.deadzone = deadzone
        self.smooth_x = 0.5
        self.smooth_y = 0.5
        self.last_valid = None

    def smooth(self, raw_data):
        if not raw_data or raw_data.get("confidence", 0.0) < 0.5:
            return self.last_valid or raw_data

        raw_x = raw_data["x"]
        raw_y = raw_data["y"]

        # Deadzone filter
        if abs(raw_x - self.smooth_x) > self.deadzone:
            self.smooth_x = self.alpha * raw_x + (1.0 - self.alpha) * self.smooth_x
        if abs(raw_y - self.smooth_y) > self.deadzone:
            self.smooth_y = self.alpha * raw_y + (1.0 - self.alpha) * self.smooth_y

        smoothed = dict(raw_data)
        smoothed["x"] = round(float(self.smooth_x), 4)
        smoothed["y"] = round(float(self.smooth_y), 4)

        self.last_valid = smoothed
        return smoothed
