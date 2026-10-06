# GRAVITY — ENDLESS FLIGHT

**GRAVITY: ENDLESS FLIGHT** is a fast-paced, keyboard-controlled 2D endless space runner and shooter built in Godot 4.x (GDScript). Inspired by the fluid momentum of *Jetpack Joyride* fused with classic sci-fi arcade space combat, the game challenges players to navigate hazardous sectors, eliminate hostile interceptors, weave through minefields and asteroid belts, and survive indefinitely.

---

## 🚀 Core Gameplay Loop

```
TITLE SCREEN / MAIN MENU
       ↓
 START FLIGHT (LAUNCH)
       ↓
    ENDLESS RUN
       ↓
SURVIVE → DODGE → SHOOT → COLLECT → UPGRADE → SCORE HIGHER
       ↓
DYNAMIC SECTORS & MINI-EVENTS (Storms, Swarms, Minefields, Dreadnoughts)
       ↓
CONTINUE ENDLESSLY
       ↓
HULL DEPLETED → GAME OVER → RUN SUMMARY & HIGH SCORE PERSISTENCE
```

---

## 🎮 Controls

The game is designed from the ground up for responsive, keyboard-first arcade precision:

| Action | Primary Key | Secondary Key | Description |
| :--- | :--- | :--- | :--- |
| **Climb (Vertical Thrust)** | `W` | `Up Arrow` | Engages vertical engines to rise swiftly |
| **Dive (Descend)** | `S` | `Down Arrow` | Decelerates / dives toward lower altitudes |
| **Micro-Adjustment** | `A` / `D` | `Left` / `Right` Arrow | Fine positioning within the flight lane |
| **Pulse Cannon Fire** | `SPACE` | — | Hold for continuous rapid plasma fire |
| **Deflector Shield** | `SHIFT` | — | Activates temporary barrier (5.0s, 12s cooldown) |
| **Screen Burst (Special)** | `E` | — | Consumes 100% Special charge for a smart-bomb wave |
| **Pause Game** | `ESC` | `P` | Opens pause menu and freezes gameplay |
| **Quick Restart** | `R` | — | Immediately restarts active run |

---

## 🌌 Key Systems & Architecture

### 1. Jetpack-Style Flight Mechanics
- **Physics**: CharacterBody2D with responsive vertical acceleration (`2200 px/s²`) and damping (`2600 px/s²`).
- **Visuals**: Continuous animated engine exhaust, banking animation frames (`up_1`, `up_2`, `straight`, `down_1`, `down_2`), and velocity-driven ship tilt.
- **Bounds**: Soft boundary clamps enforcing player flight in the left 20–30% lane of the screen.

### 2. Fair Procedural Endless Spawner & Score Scaling
- **Endless Score-Driven Density**: As your score increases, asteroid belts expand from 3 up to 8+ rocks, mine clusters widen, and ambient rogue obstacles drift into your lane with accelerating frequency!
- **10 Deterministic Spawn Patterns**: From single scouts and enemy pairs to staggered asteroid corridors, mine clusters, and reward arcs.
- **Fairness Guarantee**: Always leaves generous navigable lanes for the player; never overlaps lethal hazards across the entire screen.
- **Mini-Events**:
  - `ASTEROID STORM`: High-density rocky debris with clear flight gates.
  - `DRONE SWARM`: Coordinated interceptor and shooter formations.
  - `MINE FIELD`: Proximity mines requiring careful navigation.
  - `HIGH VALUE ZONE`: Abundant energy pickups and powerup clusters.
  - `ELITE DREADNOUGHT`: Multi-phase capital ship encounter. Defeating it awards 5,000 pts, drops powerups, and seamlessly resumes the endless flight!

### 3. Starfighter Hangar (Ship Selection & Animations)
Players can visit the **Ship Hangar** from the Main Menu to choose from 5 unique starfighters, each with dedicated banking animation frames, custom engine exhaust trail colors, bullet tints, and tactical profiles:
- **VIPER-01 [STRIKER]**: Federation multi-role fighter with balanced handling, cyan engine trails, and dependable shield recovery.
- **CRIMSON FURY [ASSAULT]**: High-output twin-turbine interceptor with flame-orange exhaust and a 12% faster rate of fire.
- **EMERALD PHANTOM [SCOUT]**: Ultra-light aerodynamic scout with emerald trails, exceptional climb speed, and sharp banking agility.
- **SOLAR PHOENIX [HEAVY]**: Titanium dread-fighter with golden solar exhaust and reinforced electromagnetic shields.
- **VOID VALKYRIE [STEALTH]**: Experimental void-drive craft with neon violet exhaust and a narrow profile for precision near-miss flight.

### 4. Combat, Upgrades & Scoring
- **Pulse Cannon**: High-speed, glowing vulcan projectiles with hit sparks and custom ship tint.
- **Powerups**:
  - **Rapid Fire**: Cooldown reduced to 0.07s.
  - **Triple Shot**: 3-way spread pattern.
  - **Deflector Shield**: Absorbs incoming damage.
  - **Hull Repair**: Restores 1 HP (up to 5 max).
  - **Score Multiplier**: Accelerates score accumulation.
  - **Overdrive**: Boosts speed and cannon velocity simultaneously.
- **Score Multiplier (Combo System)**:
  - Multiplier scales from `x1` up to `x5` with quick kills.
  - Taking hull damage or waiting >3.2 seconds resets the combo counter.
- **Near-Miss System**: Flying within close proximity of lethal obstacles awards `+25` points with a floating text badge.
- **Energy Cells**: Floating collectible pickups that award score and charge the Special Ability meter.

### 5. Audio & Presentation
- **Procedural Arcade SFX**: In-memory synthesized audio streams for laser blasts, hits, explosions, powerup chimes, shield hums, and near-miss whooshes.
- **Dark Glassmorphic UI**: High-contrast, dark sci-fi glassmorphism styling across the Flight Manual, Hangar, Pause Menu, and Game Over screens.
- **Persistence**: High score, best distance, max combo, selected starfighter, and audio preferences automatically saved to `user://gravity_save.cfg`.

---

## 🛠️ Project Structure

```
gravity/
├── scenes/
│   ├── MainMenu.tscn        # Startup title & arcade main menu
│   ├── HangarModal.tscn     # Interactive starfighter selection & animation preview
│   ├── Game.tscn            # Primary endless game scene
│   ├── Player.tscn          # Player spacecraft & exhaust components
│   ├── Bullet.tscn          # Player pulse cannon projectile
│   ├── EnemyBullet.tscn     # Enemy plasma projectile
│   ├── EnemyBasic.tscn      # Interceptor scout enemy
│   ├── EnemyShooter.tscn    # Telegraphed shooter drone
│   ├── EnemyKamikaze.tscn   # Dive-bombing kamikaze unit
│   ├── Asteroid.tscn        # Scalable rotating space rock
│   ├── Mine.tscn            # Animated drifting proximity mine
│   ├── Boss.tscn            # Elite dreadnought milestone encounter
│   ├── Powerup.tscn         # Combat powerup pickup
│   ├── EnergyPickup.tscn    # Collectible score & energy cell
│   ├── Explosion.tscn       # Animated explosion with debris particles
│   ├── FloatingText.tscn    # Floating score & near-miss text popup
│   ├── HUD.tscn             # Arcade HUD with score, combo, hull hearts
│   ├── PauseMenu.tscn       # In-game pause modal
│   ├── GameOver.tscn        # Run termination summary & records
│   └── SettingsMenu.tscn    # Volume, shake, and display settings
├── scripts/
│   ├── core/                # GameManager, ScoreManager, DifficultyManager, SaveManager
│   ├── player/              # Player flight controller & combat
│   ├── enemies/             # Enemy AI, Asteroids, Mines, and Boss
│   ├── weapons/             # Projectile scripts
│   ├── powerups/            # Powerup and Energy pickup logic
│   ├── world/               # WorldManager, SpawnManager, ParallaxBackground
│   ├── camera/              # CameraController with screen shake
│   ├── ui/                  # MainMenu, HUD, PauseMenu, GameOver, Settings
│   └── effects/             # AudioManager & FloatingText
└── assets/                  # Imported fonts, UI packs, SpaceRage artwork
```

---

## 🚦 How to Run

1. Open **Godot 4.x** (Forward+ or Compatibility mode).
2. Import the project folder: `gravity`.
3. Press **Play (F5)** to start the game directly from `res://scenes/MainMenu.tscn`.
