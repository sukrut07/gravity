class_name Player
extends CharacterBody2D

signal health_changed(current: int, max_hp: int)
signal shield_changed(is_active: bool)

@export var config: PlayerConfig

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var engine_exhaust: AnimatedSprite2D = get_node_or_null("EngineExhaust")
@onready var engine_sprite: Sprite2D = $EngineSprite
@onready var shield_sprite: Sprite2D = $ShieldSprite
@onready var muzzle: Node2D = $Muzzle
@onready var engine_particles: CPUParticles2D = $EngineParticles
@onready var input_manager: InputManager = $InputManager

# Configurable movement parameters
@export var acceleration: float = 1200.0
@export var deceleration: float = 1600.0
@export var turn_speed: float = 8.0
@export var instant_move: bool = false
@export var max_speed: float = 900.0

@export var jump_duration: float = 0.35
@export var jump_height: float = 180.0
@export var down_gravity: float = 850.0
@export var air_acceleration: float = 900.0
@export var air_control: float = 1.0
@export var air_brake: float = 700.0
@export var jump_cutoff_level: float = 0.25
@export var double_jump: bool = true

@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var terminal_velocity: float = 1000.0

# Combat State
var health: int = 1
var max_health: int = 1
var is_shield_active: bool = false
var shield_timer: float = 0.0
var invulnerable_timer: float = 0.0

# Shooting State
var shoot_cooldown_timer: float = 0.0
var rapid_fire_active: bool = false
var triple_shot_active: bool = false
var laser_active: bool = false
var magnet_active: bool = false
var powerup_timer: float = 0.0

# Scenes
var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")

func _ready() -> void:
	add_to_group("player")
	if config != null:
		acceleration = config.acceleration
		deceleration = config.deceleration
		turn_speed = config.turn_speed
		instant_move = config.instant_move
		max_speed = config.max_speed
		jump_duration = config.jump_duration
		jump_height = config.jump_height
		down_gravity = config.down_gravity
		air_acceleration = config.air_acceleration
		air_control = config.air_control
		air_brake = config.air_brake
		jump_cutoff_level = config.jump_cutoff_level
		double_jump = config.double_jump
		coyote_time = config.coyote_time
		jump_buffer_time = config.jump_buffer_time
		terminal_velocity = config.terminal_velocity
		health = config.max_health
		max_health = config.max_health
	
	if anim_sprite == null and sprite != null and sprite.texture == null:
		sprite.texture = ProceduralAssets.create_player_texture()
	if engine_sprite != null and engine_sprite.texture == null and engine_exhaust == null:
		engine_sprite.texture = ProceduralAssets.create_engine_flame_texture()
	if shield_sprite != null and shield_sprite.texture == null:
		shield_sprite.texture = ProceduralAssets.create_powerup_texture(Color(0.2, 0.7, 1.0, 0.4))
	
	if shield_sprite != null:
		shield_sprite.visible = false

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# Update timers
	if shield_timer > 0.0:
		shield_timer -= delta
		if shield_timer <= 0.0:
			deactivate_shield()
	
	if invulnerable_timer > 0.0:
		invulnerable_timer -= delta
	
	if shoot_cooldown_timer > 0.0:
		shoot_cooldown_timer -= delta
		
	if powerup_timer > 0.0:
		powerup_timer -= delta
		if powerup_timer <= 0.0:
			reset_powerups()

	# Read Input
	var move_vec = input_manager.get_move_vector()

	# Natural Jetpack Flight Physics
	var target_vel = move_vec * max_speed
	
	# Vertical movement from gesture move_y or keyboard
	if move_vec.y < -0.05: # Upward thrust
		velocity.y = move_toward(velocity.y, move_vec.y * max_speed, air_acceleration * delta)
	elif move_vec.y > 0.05: # Downward dive
		velocity.y = move_toward(velocity.y, move_vec.y * max_speed, down_gravity * delta * 1.5)
	else: # Neutral flight damping
		velocity.y = move_toward(velocity.y, 0.0, air_brake * delta)
	
	# Horizontal positioning
	if abs(move_vec.x) > 0.05:
		velocity.x = move_toward(velocity.x, target_vel.x * 0.5, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
	
	velocity.y = clampf(velocity.y, -terminal_velocity, terminal_velocity)
	move_and_slide()

	# Enforce Flight Screen Boundaries
	var vp_size = get_viewport_rect().size
	global_position.x = clampf(global_position.x, 60.0, 480.0)
	global_position.y = clampf(global_position.y, 50.0, vp_size.y - 50.0)

	# Visual Lean angle (-12 to +12 degrees)
	var target_rotation = clampf(velocity.y / max_speed, -1.0, 1.0) * deg_to_rad(12.0)
	rotation = lerpf(rotation, target_rotation, delta * turn_speed)

	# Update SpaceRage banking animations
	if anim_sprite != null:
		if velocity.y < -180.0:
			anim_sprite.animation = "up_2"
		elif velocity.y < -50.0:
			anim_sprite.animation = "up_1"
		elif velocity.y > 180.0:
			anim_sprite.animation = "down_2"
		elif velocity.y > 50.0:
			anim_sprite.animation = "down_1"
		else:
			anim_sprite.animation = "straight"

	# Modulate exhaust speed with movement
	if engine_exhaust != null:
		engine_exhaust.speed_scale = 1.0 + clampf(abs(velocity.x) / max_speed, 0.0, 1.0) * 0.5

	# Weapon Firing
	if input_manager.is_shooting():
		try_shoot()
		
	if input_manager.is_shield_active() and not is_shield_active:
		activate_shield(3.0)

func try_shoot() -> void:
	if shoot_cooldown_timer > 0.0:
		return
	
	var rate = 0.1 if rapid_fire_active else (config.fire_rate if config else 0.15)
	shoot_cooldown_timer = rate
	
	AudioManager.play_sound("cannon_fire")
	
	if triple_shot_active:
		for angle in [-0.2, 0.0, 0.2]:
			spawn_bullet(angle)
	else:
		spawn_bullet(0.0)

func spawn_bullet(angle_offset: float) -> void:
	GameManager.record_shot_fired()
	var bullet = bullet_scene.instantiate() as Node2D
	get_parent().add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.rotation = rotation + angle_offset

func activate_shield(duration: float) -> void:
	is_shield_active = true
	shield_timer = duration
	if shield_sprite != null:
		shield_sprite.visible = true
	AudioManager.play_sound("shield_activate")
	emit_signal("shield_changed", true)

func deactivate_shield() -> void:
	is_shield_active = false
	if shield_sprite != null:
		shield_sprite.visible = false
	emit_signal("shield_changed", false)

func take_damage() -> void:
	if invulnerable_timer > 0.0:
		return
		
	if is_shield_active:
		deactivate_shield()
		invulnerable_timer = 1.0
		AudioManager.play_sound("shield_hit")
		return
		
	health -= 1
	AudioManager.play_sound("player_hit")
	emit_signal("health_changed", health, max_health)
	
	if health <= 0:
		die()

func die() -> void:
	visible = false
	if explosion_scene != null:
		var expl = explosion_scene.instantiate()
		if expl != null:
			get_parent().add_child(expl)
			expl.global_position = global_position
			if expl.has_method("set_explosion_type"):
				expl.set_explosion_type("large")
	GameManager.trigger_game_over()

func apply_powerup(type: String, duration: float) -> void:
	AudioManager.play_sound("powerup_pickup")
	GameManager.record_powerup_collected()
	powerup_timer = duration
	match type:
		"rapid_fire":
			rapid_fire_active = true
		"shield":
			activate_shield(duration)
		"triple_shot":
			triple_shot_active = true
		"health":
			health = min(health + 1, 3)
			emit_signal("health_changed", health, max_health)
		"multiplier":
			GameManager.score_multiplier = 2

func reset_powerups() -> void:
	rapid_fire_active = false
	triple_shot_active = false
	laser_active = false
	magnet_active = false
	GameManager.score_multiplier = 1
