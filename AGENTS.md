# AGENTS.md - Development Rules & Guidelines for Gravity: Endless Flight

- **Keep GDScript simple**: Write clean, readable GDScript 2.0 code. Use type hints (`: int`, `: Vector2`, `-> void`) for performance and safety.
- **Prefer small scripts**: Single responsibility per script. Do not put all gameplay logic into one massive controller file.
- **Avoid unnecessary dependencies**: Rely on native Godot 4.x features, nodes, and built-in shaders.
- **Use signals where useful**: Decouple components using signals (`player_died`, `score_changed`, `combo_changed`, `tier_changed`).
- **Use exported variables**: Expose all tunable gameplay parameters (`@export var vertical_acceleration: float = 2200.0`) for easy adjustment in the Godot Inspector.
- **Responsive keyboard controls**: Game is built for keyboard precision (WASD / Arrow Keys, Space for fire, Shift for shield, E for special, Esc/P for pause).
- **Never hard-code asset paths**: Use exported properties or centralized resource configurations.
- **Use reusable scenes**: Build components as self-contained scenes (`Player.tscn`, `Bullet.tscn`, `EnemyBasic.tscn`, `Asteroid.tscn`, `Powerup.tscn`).
- **Object pooling & performance**: Maintain high 60 FPS performance by recycling or freeing projectiles and particles when exiting screen bounds.
- **Modular managers**: Encapsulate distinct domains in dedicated autoload managers (`GameManager`, `ScoreManager`, `DifficultyManager`, `SaveManager`, `AudioManager`).
- **Document non-obvious systems**: Add concise GDScript docstrings to explain math formulas, procedural generation, and physics logic.
- **Test after every major change**: Validate syntax and run headless checks before proceeding to the next phase.
- **Never silently ignore errors**: Handle null checks and boundary bounds cleanly.
- **Preserve working functionality**: When extending features, ensure baseline controls and gameplay remain operational.
