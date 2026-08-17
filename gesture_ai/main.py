import cv2
import time
from hand_tracker import HandTracker
from gesture_detector import GestureDetector
from gesture_smoother import GestureSmoother
from udp_sender import UDPSender

def main():
    print("=" * 60)
    print(" GESTURE FIGHTER - MEDIAPIPE AI HAND TRACKER & UDP TRANSMITTER")
    print(" Target: 127.0.0.1:4242")
    print(" Press 'q' or ESC in webcam window to quit.")
    print("=" * 60)

    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("[ERROR] Could not open webcam camera index 0.")
        print("Falling back: Godot game will run seamlessly in KEYBOARD MODE.")
        return

    tracker = HandTracker()
    detector = GestureDetector()
    smoother = GestureSmoother()
    sender = UDPSender(host="127.0.0.1", port=4242)

    prev_time = time.time()

    while True:
        ret, frame = cap.read()
        if not ret:
            print("[WARN] Failed to grab frame from webcam.")
            break

        # Flip horizontally for natural mirror interaction
        frame = cv2.flip(frame, 1)

        # Process Landmarks & Classify Gestures
        landmarks, annotated_frame = tracker.process_frame(frame)
        raw_gesture = detector.classify_gesture(landmarks)
        smoothed_gesture = smoother.smooth(raw_gesture)

        # Broadcast UDP JSON packet to Godot
        sender.send_gesture_packet(smoothed_gesture)

        # Calculate FPS
        curr_time = time.time()
        fps = 1.0 / max(0.001, curr_time - prev_time)
        prev_time = curr_time

        # Draw HUD info on OpenCV window
        g_name = smoothed_gesture.get("gesture_name", "NONE")
        gx = smoothed_gesture.get("x", 0.5)
        gy = smoothed_gesture.get("y", 0.5)
        conf = int(smoothed_gesture.get("confidence", 0.0) * 100)

        cv2.putText(annotated_frame, f"GESTURE: {g_name}", (20, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
        cv2.putText(annotated_frame, f"POS: ({gx:.2f}, {gy:.2f})  CONF: {conf}%", (20, 75), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
        cv2.putText(annotated_frame, f"FPS: {fps:.1f} | UDP -> 127.0.0.1:4242", (20, 105), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)

        cv2.imshow("Gesture Fighter - MediaPipe Tracker", annotated_frame)

        key = cv2.waitKey(1) & 0xFF
        if key == ord('q') or key == 27:
            break

    cap.release()
    cv2.destroyAllWindows()
    sender.close()
    print("[INFO] Gesture tracker closed successfully.")

if __name__ == "__main__":
    main()
