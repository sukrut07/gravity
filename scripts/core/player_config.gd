class_name PlayerConfig
extends Resource

@export_group("Running / Flight Movement")
@export var acceleration: float = 1200.0
@export var deceleration: float = 1600.0
@export var turn_speed: float = 8.0
@export var instant_move: bool = false
@export var max_speed: float = 900.0

@export_group("Jetpack Flight Adaptation")
@export var jump_duration: float = 0.35
@export var jump_height: float = 180.0
@export var down_gravity: float = 850.0
@export var air_acceleration: float = 900.0
@export var air_control: float = 1.0
@export var air_brake: float = 700.0
@export var jump_cutoff_level: float = 0.25
@export var double_jump: bool = true

@export_group("Assists")
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var terminal_velocity: float = 1000.0

@export_group("Combat & Protection")
@export var max_health: int = 1
@export var shield_duration: float = 6.0
@export var fire_rate: float = 0.15 # seconds between cannon shots
