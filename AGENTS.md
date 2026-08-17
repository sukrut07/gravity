# AGENTS.md - Development Rules & Guidelines for Gesture Fighter

- **Keep GDScript simple**: Write clean, readable GDScript 2.0 code. Use type hints (`: int`, `: Vector2`, `-> void`) for performance and safety.
- **Prefer small scripts**: Single responsibility per script. Do not put all gameplay logic into one massive controller file.
- **Avoid unnecessary dependencies**: Rely on native Godot 4.x features, nodes, and built-in shaders.
- **Use signals where useful**: Decouple components using signals (`player_died`, `score_changed`, `gesture_received`).
- **Use exported variables**: Expose all tunable gameplay parameters (`@export var max_speed: float = 900.0`) for easy adjustment in the Godot Inspector.
- **Decouple input from gameplay**: `Player` and game entities only read abstract inputs from `InputManager`. Gameplay MUST work seamlessly with keyboard or gesture input.
- **Keyboard fallback ALWAYS available**: Never block gameplay if webcam/UDP/MediaPipe is offline.
- **Never hard-code asset paths**: Use exported properties or centralized resource configurations.
- **Use reusable scenes**: Build components as self-contained scenes (`Player.tscn`, `Bullet.tscn`, `EnemyBasic.tscn`, `Asteroid.tscn`, `Powerup.tscn`).
- **Object pooling**: Use object pools for high-frequency nodes like bullets, particles, and small asteroids to maintain 60 FPS.
- **Avoid unnecessary global state**: Encapsulate logic in dedicated managers (`ScoreManager`, `DistanceManager`, `DifficultyManager`).
- **Document non-obvious systems**: Add concise GDScript docstrings to explain math formulas, UDP packet format, and physics logic.
- **Test after every major change**: Validate syntax and run headless checks before proceeding to the next phase.
- **Never silently ignore errors**: Handle null checks, UDP parse exceptions, and bounds cleanly.
- **Preserve working functionality**: When extending features, ensure baseline controls and gameplay remain operational.
