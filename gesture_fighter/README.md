# GESTURE FIGHTER - 2D Endless Gesture-Controlled Fighter Jet Shooter

**GESTURE FIGHTER** is an arcade-style endless side-scrolling 2D fighter jet runner/shooter built in Godot 4.x (GDScript) with a standalone Python 3 MediaPipe computer-vision application communicating high-frequency control packets over UDP JSON.

The jet is controlled in real time using hand gestures detected via webcam, with a seamless keyboard fallback whenever the webcam or gesture application is offline.

---

## 🚀 Key Features

- **Fighter Jet Flight Physics**: Responsive vertical thrust, horizontal positioning, tilt/lean visual feedback, coyote time, and flight boundary clamps.
- **Dual Input Architecture**: Decoupled input pipeline using `InputManager`. Automatically switches between `GestureInput` (via UDP) and `KeyboardInput` (WASD / Arrows / Space / Shift / Esc).
- **Procedural Visual System**: Generated sci-fi 2D procedural textures for Player Jet, Enemies, Asteroids, Boss, Powerups, Projectiles, and Starfield Parallax — zero external assets required to run.
- **Dynamic Difficulty & Endless World**: Procedurally spawned asteroids, basic fighters, shooter drones, kamikaze interceptors, and a 3-phase Boss encounter at 3000m.
- **Powerups**: Rapid Fire, Shield, Triple Shot, Restore Health, and Score Multiplier.
- **Python MediaPipe Computer Vision**: Real-time hand landmark tracking, gesture classification (Index Shoot, Fist Shield, Open Palm Pause, Two-Finger Special), EMA smoothing, and deadzone filtering broadcasting at 30–60 Hz over UDP `127.0.0.1:4242`.

---

## 🎮 Controls

### Keyboard Controls (Always Active Fallback)

| Action | Key |
| :--- | :--- |
| **Move Up / Down** | `W` / `S` or `Up` / `Down` Arrow |
| **Move Left / Right** | `A` / `D` or `Left` / `Right` Arrow |
| **Primary Cannon Fire** | `SPACE` |
| **Activate Shield** | `SHIFT` |
| **Special Weapon Hook** | `E` |
| **Pause Game** | `ESC` |
| **Gesture Debug Overlay** | `F3` |

### Gesture Controls (Webcam Mode)

| Action | Hand Gesture |
| :--- | :--- |
| **Flight Altitude & Position** | Move Hand Up / Down / Left / Right |
| **Fire Cannons** | Extend **Index Finger** |
| **Activate Shield** | Make a **Closed Fist** |
| **Special Ability** | Show **Two Fingers** (Victory sign) |
| **Pause Game** | Show **Open Palm** |

---

## 🛠️ Project Structure

```
gesture_fighter/
├── AGENTS.md                   # Development rules & guidelines
├── README.md                   # Complete documentation & usage guide
├── gesture_ai/                 # Standalone Python MediaPipe app
│   ├── main.py                 # Main entry point & webcam preview window
│   ├── hand_tracker.py         # MediaPipe hand landmarker wrapper
│   ├── gesture_detector.py     # Geometric gesture classification rules
│   ├── gesture_smoother.py     # Exponential moving average & deadzone smoothing
│   ├── udp_sender.py           # UDP socket packet transmitter (port 4242)
│   ├── calibration.py          # Coordinate normalization & sensitivity helper
│   └── requirements.txt        # opencv-python, mediapipe, numpy
└── godot/                      # Godot 4.x engine project
    ├── project.godot           # Project configuration
    ├── scenes/
    │   ├── Main.tscn           # Root game scene
    │   ├── Player.tscn         # Player jet node & components
    │   ├── Bullet.tscn         # Cannon projectile
    │   ├── EnemyBasic.tscn     # Red interceptor enemy
    │   ├── EnemyShooter.tscn   # Shooter drone enemy
    │   ├── EnemyKamikaze.tscn  # Kamikaze drone enemy
    │   ├── Asteroid.tscn       # Procedural asteroid
    │   ├── Boss.tscn           # Multi-phase flagship boss
    │   ├── Powerup.tscn        # Collectible powerup items
    │   ├── HUD.tscn            # High-tech sci-fi HUD overlay
    │   ├── PauseMenu.tscn      # Pause menu screen
    │   ├── GameOver.tscn       # Game over results screen
    │   └── CalibrationScreen.tscn # In-game calibration overlay
    ├── scripts/
    │   ├── core/               # GameManager, ProceduralAssets, Configs
    │   ├── player/             # Player jet flight physics & weapons
    │   ├── enemies/            # Enemy AI & Boss phases
    │   ├── weapons/            # Bullet & projectile logic
    │   ├── powerups/           # Powerup manager & pickups
    │   ├── world/              # WorldManager & StarfieldParallax
    │   ├── camera/             # CameraController & ScreenShake
    │   ├── input/              # InputManager, UDPReceiver, GestureInput, KeyboardInput
    │   ├── ui/                 # HUD, Pause, GameOver, Calibration UI
    │   └── effects/            # AudioManager & visual effects hooks
    └── data/                   # Player, Enemy, Weapon, Difficulty .tres resources
```

---

## 🚦 How to Run

### 1. Launch Python Gesture AI Tracker (Webcam Mode)

```bash
cd gesture_fighter/gesture_ai
pip install -r requirements.txt
python3 main.py
```

*An OpenCV window will appear displaying live camera feed, hand landmarks, detected gesture name, FPS, and UDP broadcasting status.*

### 2. Launch Godot Game

```bash
# Launch using Godot 4 editor or executable:
godot --path gesture_fighter/godot
```

---

## 📡 UDP Communication Protocol

- **Transport**: UDP Unicast
- **Host**: `127.0.0.1`
- **Port**: `4242`
- **Packet Format**: JSON (UTF-8 encoded string)

```json
{
  "x": 0.52,
  "y": 0.34,
  "shoot": true,
  "shield": false,
  "special": false,
  "pause": false,
  "confidence": 0.94,
  "timestamp": 1723886400123
}
```

---

## 🔧 Customization & Extension Guide

### How to Add Custom Assets
Assign your `.png` or `.svg` textures to the exported `texture` properties on `Player.tscn`, `EnemyBasic.tscn`, or `Asteroid.tscn` via the Godot Inspector. If no texture is assigned, `ProceduralAssets` generates sci-fi textures automatically.

### How to Modify Difficulty
Edit `godot/data/difficulty_config.tres`:
- `base_speed`: Base scrolling speed
- `speed_increase_per_100m`: Rate of difficulty scaling
- `initial_spawn_interval`: Seconds between enemy/asteroid spawns
- `boss_distance_meters`: Distance milestone for Boss arrival (default `3000.0` meters)

---

## 🩺 Troubleshooting

- **Webcam Not Detected**: Ensure webcam permissions are granted. If webcam is unavailable, the game automatically operates in Keyboard Mode without crashing.
- **Godot UDP Not Receiving**: Verify firewall allows local UDP traffic on port `4242`. Press `F3` in-game to open the gesture debug panel and check UDP status.
