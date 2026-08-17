import cv2
import sys
import time

try:
    import mediapipe as mp
    mp_hands = mp.solutions.hands
    mp_drawing = mp.solutions.drawing_utils
    HAS_MEDIAPIPE = True
    MP_VERSION = mp.__version__
except Exception as e:
    HAS_MEDIAPIPE = False
    MP_VERSION = f"Not available ({e})"

def test_camera():
    print("=" * 65)
    print(" GRAVITY — MACOS CAMERA & MEDIAPIPE HAND LANDMARK TEST")
    print(f" MediaPipe Version: {MP_VERSION}")
    print(f" OpenCV Version:    {cv2.__version__}")
    print(" Press 'q' or 'ESC' in the window to quit.")
    print("=" * 65)

    # Attempt opening camera 0 with AVFoundation backend for macOS
    cap = cv2.VideoCapture(0, cv2.CAP_AVFOUNDATION)
    if not cap.isOpened():
        # Fallback to default backend
        cap = cv2.VideoCapture(0)

    # Set preferred resolution to 640x480 for low latency
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

    # Read a test frame to confirm hardware access
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
        print("Then re-run this script.")
        print("!" * 65 + "\n")
        cap.release()
        return False

    actual_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    actual_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    print(f"\n[SUCCESS] Camera opened successfully! Resolution: {actual_w}x{actual_h}")

    hands = None
    if HAS_MEDIAPIPE:
        hands = mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=1,
            min_detection_confidence=0.7,
            min_tracking_confidence=0.6
        )
        print("[INFO] MediaPipe Hands landmarker initialized.")
    else:
        print("[WARN] MediaPipe is not installed; running raw camera preview.")

    prev_time = time.time()

    try:
        while True:
            ret, frame = cap.read()
            if not ret or frame is None:
                print("[WARN] Failed to read frame from webcam.")
                time.sleep(0.02)
                continue

            # Mirror horizontally for natural mirror feel
            frame = cv2.flip(frame, 1)
            h, w, _ = frame.shape

            hand_detected = False
            if hands:
                rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                rgb_frame.flags.writeable = False
                results = hands.process(rgb_frame)
                rgb_frame.flags.writeable = True

                if results.multi_hand_landmarks:
                    hand_detected = True
                    for hand_landmarks in results.multi_hand_landmarks:
                        mp_drawing.draw_landmarks(
                            frame,
                            hand_landmarks,
                            mp_hands.HAND_CONNECTIONS,
                            mp_drawing.DrawingSpec(color=(0, 255, 255), thickness=2, circle_radius=3),
                            mp_drawing.DrawingSpec(color=(255, 0, 255), thickness=2)
                        )

            # FPS calculation
            curr_time = time.time()
            fps = 1.0 / max(0.001, curr_time - prev_time)
            prev_time = curr_time

            # Status Overlay
            status_str = "HAND: DETECTED" if hand_detected else "HAND: SEARCHING..."
            status_color = (0, 255, 0) if hand_detected else (0, 200, 255)

            cv2.rectangle(frame, (10, 10), (w - 10, 80), (20, 20, 20), -1)
            cv2.rectangle(frame, (10, 10), (w - 10, 80), (0, 200, 255), 1)
            cv2.putText(frame, f"{status_str} | FPS: {fps:.1f}", (20, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.65, status_color, 2)
            cv2.putText(frame, f"Resolution: {w}x{h} | Press 'q' to Quit", (20, 68), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

            cv2.imshow("Gravity — macOS Camera & MediaPipe Test", frame)

            key = cv2.waitKey(1) & 0xFF
            if key == ord('q') or key == 27:
                break

    except KeyboardInterrupt:
        pass
    finally:
        if hands:
            hands.close()
        cap.release()
        cv2.destroyAllWindows()
        print("\n[INFO] Camera test closed cleanly.")

    return True

if __name__ == "__main__":
    test_camera()
