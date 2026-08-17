import cv2
import time
import sys
from hand_tracker import HandTracker
from gesture_detector import GestureDetector
from gesture_smoother import GestureSmoother
from udp_sender import UDPSender

def main():
    print("=" * 65)
    print(" GRAVITY - REAL-TIME MEDIAPIPE GESTURE CONTROLLER")
    print(" Target UDP: 127.0.0.1:4242")
    print(" Press 'q' or 'ESC' in the camera preview window to quit.")
    print("=" * 65)

    # Attempt opening camera 0 with AVFoundation backend for macOS
    cap = cv2.VideoCapture(0, cv2.CAP_AVFOUNDATION)
    if not cap.isOpened():
        cap = cv2.VideoCapture(0)

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

    ret, test_frame = cap.read()
    if not ret or test_frame is None:
        print("\n" + "!" * 65)
        print(" CAMERA ACCESS REQUIRED")
        print("!" * 65)
        print("Could not access the Mac camera stream.")
        print("\nPlease allow camera access for the application running this")
        print("Python process (Terminal / iTerm / VSCode / Cursor / IDE) in:\n")
        print("  System Settings")
        print("  -> Privacy & Security")
        print("  -> Camera")
        print("  -> (Toggle ON for your terminal / app)\n")
        print("Falling back: Godot game will run seamlessly in KEYBOARD MODE.")
        print("!" * 65 + "\n")
        cap.release()
        return

    tracker = HandTracker(max_num_hands=1, min_detection_confidence=0.7, min_tracking_confidence=0.6)
    detector = GestureDetector(deadzone_top=0.40, deadzone_bottom=0.60)
    smoother = GestureSmoother(alpha=0.25, debounce_frames=3, timeout_sec=0.2)
    sender = UDPSender(host="127.0.0.1", port=4242)

    prev_time = time.time()
    print("[INFO] Camera feed active. Processing gestures at 30-60 FPS...")

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("[WARN] Failed to grab frame from webcam.")
                time.sleep(0.02)
                continue

            # Mirror horizontal flip for natural intuitive interaction
            frame = cv2.flip(frame, 1)
            h, w, _ = frame.shape

            # Process MediaPipe hand landmarks
            landmarks, annotated_frame = tracker.process_frame(frame)
            raw_data = detector.classify_gesture(landmarks)
            smoothed_data = smoother.smooth(raw_data)

            # Transmit UDP JSON packet to Godot
            sender.send_gesture_packet(smoothed_data)

            # FPS calculation
            curr_time = time.time()
            fps = 1.0 / max(0.001, curr_time - prev_time)
            prev_time = curr_time

            # Draw visual dead-zone guide lines (40% and 60% height)
            y_top = int(h * 0.40)
            y_bot = int(h * 0.60)
            cv2.line(annotated_frame, (0, y_top), (w, y_top), (80, 80, 80), 1, cv2.LINE_AA)
            cv2.line(annotated_frame, (0, y_bot), (w, y_bot), (80, 80, 80), 1, cv2.LINE_AA)
            cv2.putText(annotated_frame, "UP ZONE", (10, y_top - 6), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 200, 255), 1)
            cv2.putText(annotated_frame, "DEAD ZONE (NEUTRAL)", (10, y_top + 20), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (100, 100, 100), 1)
            cv2.putText(annotated_frame, "DOWN ZONE", (10, y_bot + 16), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 200, 255), 1)

            # HUD Display
            is_detected = smoothed_data.get("hand_detected", False)
            g_name = smoothed_data.get("gesture", "NONE")
            move_y = smoothed_data.get("move_y", 0.0)
            shoot = smoothed_data.get("shoot", False)
            shield = smoothed_data.get("shield", False)
            special = smoothed_data.get("special", False)
            conf = int(smoothed_data.get("confidence", 0.0) * 100)

            move_label = "UP" if move_y < -0.1 else ("DOWN" if move_y > 0.1 else "NEUTRAL")
            move_color = (0, 255, 0) if move_label == "NEUTRAL" else (0, 255, 255)

            # Top HUD Bar
            cv2.rectangle(annotated_frame, (10, 10), (w - 10, 110), (20, 20, 20), -1)
            cv2.rectangle(annotated_frame, (10, 10), (w - 10, 110), (0, 200, 255), 1)

            status_text = f"HAND: {'DETECTED' if is_detected else 'NO HAND'} ({conf}%) | GESTURE: {g_name}"
            cv2.putText(annotated_frame, status_text, (20, 35), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (0, 255, 255), 2)

            move_text = f"MOVE: {move_label} (val: {move_y:+.2f}) | FPS: {fps:.1f}"
            cv2.putText(annotated_frame, move_text, (20, 65), cv2.FONT_HERSHEY_SIMPLEX, 0.55, move_color, 1)

            action_text = f"SHOOT: {'YES' if shoot else 'NO'} | SHIELD: {'YES' if shield else 'NO'} | SPECIAL: {'YES' if special else 'NO'}"
            cv2.putText(annotated_frame, action_text, (20, 95), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

            # Bottom status
            cv2.putText(annotated_frame, "UDP: 127.0.0.1:4242 | Press 'q' to Quit", (20, h - 15), cv2.FONT_HERSHEY_SIMPLEX, 0.45, (0, 255, 0), 1)

            cv2.imshow("Gravity - MediaPipe Gesture Controller", annotated_frame)

            key = cv2.waitKey(1) & 0xFF
            if key == ord('q') or key == 27:
                break

    except KeyboardInterrupt:
        pass
    finally:
        cap.release()
        cv2.destroyAllWindows()
        tracker.close()
        sender.close()
        print("\n[INFO] Gesture controller closed cleanly.")

if __name__ == "__main__":
    main()
