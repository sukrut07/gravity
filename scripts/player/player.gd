class_name Player
extends CharacterBody2D

## High-performance, responsive player spacecraft for Gravity: Endless Flight.
## Keyboard-first vertical runner controls inspired by the responsive feel of Jetpack Joyride.

signal health_changed(current: int, max_hp: int)
signal shield_changed(is_active: bool, duration: float)
signal special_activated()
signal player_died()

# Movement Tuning (exposed in Inspector)
@export var vertical_acceleration: float = 2200.0
@export var vertical_deceleration: float = 2600.0
@export var max_vertical_speed: float = 680.0
@export var horizontal_speed: float = 300.0
@export var turn_speed: float = 12.0

# Combat Parameters
@export var max_health: int = 5
var health: int = 5

@export var base_fire_rate: float = 0.14
var shoot_cooldown_timer: float = 0.0

# Defenses & Abilities
var is_shield_active: bool = false
var shield_timer: float = 0.0
var shield_cooldown_timer: float = 0.0
const SHIELD_COOLDOWN_MAX: float = 12.0
var invulnerable_timer: float = 0.0

# Powerup States
var rapid_fire_active: bool = false
var triple_shot_active: bool = false
var overdrive_active: bool = false
var active_powerup_type: String = ""
var powerup_timer: float = 0.0

# Visual Nodes
@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var engine_exhaust: AnimatedSprite2D = get_node_or_null("EngineExhaust")
@onready var engine_particles: CPUParticles2D = get_node_or_null("EngineParticles")
@onready var shield_sprite: Sprite2D = get_node_or_null("ShieldSprite")
@onready var muzzle: Node2D = get_node_or_null("Muzzle")

# Scenes
var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")

var current_bullet_color: Color = Color(0.2, 0.9, 1.0, 1.0)

func _ready() -> void:
	add_to_group("player")
	apply_ship_configuration()
	health = max_health
	emit_signal("health_changed", health, max_health)
	
	if shield_sprite != null:
		if shield_sprite.texture == null:
			shield_sprite.texture = ProceduralAssets.create_powerup_texture(Color(0.2, 0.8, 1.0, 0.45))
		shield_sprite.visible = false

func apply_ship_configuration() -> void:
	var ship = SaveManager.get_current_ship_data()
	if anim_sprite != null:
		anim_sprite.sprite_frames = ShipData.create_sprite_frames_for_ship(ship)
		anim_sprite.animation = "straight"
		anim_sprite.play()
	
	if engine_particles != null:
		engine_particles.color = ship.get("trail_color", Color(0.2, 0.8, 1.0, 0.6))
		
	current_bullet_color = ship.get("bullet_color", Color(0.2, 0.9, 1.0, 1.0))
	
	# Apply ship traits
	max_vertical_speed = 680.0 * ship.get("speed_mod", 1.0)
	turn_speed = 12.0 * ship.get("turn_mod", 1.0)
	base_fire_rate = 0.14 * ship.get("fire_rate_mod", 1.0)

func _physics_process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_update_timers(delta)
	_handle_movement(delta)
	_handle_combat(delta)

func _update_timers(delta: float) -> void:
	if shoot_cooldown_timer > 0.0:
		shoot_cooldown_timer -= delta
		
	if invulnerable_timer > 0.0:
		invulnerable_timer -= delta
		# Subtle blink while invulnerable
		if anim_sprite != null:
			anim_sprite.modulate.a = 0.5 if fmod(invulnerable_timer, 0.16) > 0.08 else 1.0
	else:
		if anim_sprite != null and anim_sprite.modulate.a < 0.99:
			anim_sprite.modulate.a = 1.0
			
	if shield_timer > 0.0:
		shield_timer -= delta
		emit_signal("shield_changed", true, shield_timer)
		if shield_timer <= 0.0:
			deactivate_shield()
			
	if shield_cooldown_timer > 0.0:
		shield_cooldown_timer -= delta
		
	if powerup_timer > 0.0:
		powerup_timer -= delta
		if powerup_timer <= 0.0:
			reset_powerups()

func _handle_movement(delta: float) -> void:
	# Read vertical inputs
	var move_y: float = 0.0
	if Input.is_action_pressed("move_up"):
		move_y -= 1.0
	if Input.is_action_pressed("move_down"):
		move_y += 1.0
		
	# Read micro-horizontal inputs
	var move_x: float = 0.0
	if Input.is_action_pressed("move_left"):
		move_x -= 1.0
	if Input.is_action_pressed("move_right"):
		move_x += 1.0
		
	var speed_mult = 1.25 if overdrive_active else 1.0
	var cur_max_v = max_vertical_speed * speed_mult
	
	# Responsive Jetpack Joyride vertical acceleration / deceleration
	if move_y < -0.05: # Upward thrust
		velocity.y = move_toward(velocity.y, move_y * cur_max_v, vertical_acceleration * delta)
	elif move_y > 0.05: # Downward dive
		velocity.y = move_toward(velocity.y, move_y * cur_max_v, vertical_acceleration * delta)
	else: # Snappy centering / damping
		velocity.y = move_toward(velocity.y, 0.0, vertical_deceleration * delta)
		
	# Micro horizontal adjustment
	if abs(move_x) > 0.05:
		velocity.x = move_toward(velocity.x, move_x * horizontal_speed, vertical_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, vertical_deceleration * delta)
		
	move_and_slide()

	# Enforce Strict Soft Viewport Screen Boundaries (left 20-30% range)
	var vp_size = get_viewport_rect().size
	global_position.x = clampf(global_position.x, 90.0, 380.0)
	global_position.y = clampf(global_position.y, 45.0, vp_size.y - 45.0)

	# Visual Tilt Banking Angle
	var target_rot = clampf(velocity.y / max_vertical_speed, -1.0, 1.0) * deg_to_rad(12.0)
	rotation = lerpf(rotation, target_rot, delta * turn_speed)

	# SpaceRage Banking Animation Frames
	if anim_sprite != null:
		if velocity.y < -190.0:
			anim_sprite.animation = "up_2"
		elif velocity.y < -50.0:
			anim_sprite.animation = "up_1"
		elif velocity.y > 190.0:
			anim_sprite.animation = "down_2"
		elif velocity.y > 50.0:
			anim_sprite.animation = "down_1"
		else:
			anim_sprite.animation = "straight"

	# Modulate Exhaust Speed
	if engine_exhaust != null:
		engine_exhaust.speed_scale = 1.2 + clampf(abs(velocity.y) / max_vertical_speed, 0.0, 1.0) * 0.8

func _handle_combat(delta: float) -> void:
	# Space held = continuous pulse cannon firing
	if Input.is_action_pressed("shoot"):
		try_shoot()
		
	# Shift = manual shield activation (if off cooldown and not currently shielded)
	if Input.is_action_just_pressed("shield"):
		if not is_shield_active and shield_cooldown_timer <= 0.0:
			activate_shield(5.0)
			shield_cooldown_timer = SHIELD_COOLDOWN_MAX
			
	# E = Special Screen Burst Ability
	if Input.is_action_just_pressed("special"):
		if GameManager.consume_special():
			execute_screen_burst()

func try_shoot() -> void:
	if shoot_cooldown_timer > 0.0:
		return
		
	var rate = 0.07 if (rapid_fire_active or overdrive_active) else base_fire_rate
	shoot_cooldown_timer = rate
	
	AudioManager.play_sound("cannon_fire")
	
	var m_pos = muzzle.global_position if muzzle != null else global_position
	
	if triple_shot_active:
		for angle in [-0.18, 0.0, 0.18]:
			spawn_bullet(m_pos, angle)
	else:
		spawn_bullet(m_pos, 0.0)

func spawn_bullet(spawn_pos: Vector2, angle_offset: float) -> void:
	GameManager.record_shot_fired()
	if bullet_scene != null:
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = spawn_pos
		bullet.rotation = rotation + angle_offset
		bullet.modulate = current_bullet_color

func execute_screen_burst() -> void:
	emit_signal("special_activated")
	AudioManager.play_sound("special_blast")
	
	# Massive camera shake
	var cams = get_tree().get_nodes_in_group("camera")
	if cams.size() > 0 and cams[0].has_method("shake"):
		cams[0].shake(0.5, 14.0)
		
	# Screen-clearing pulse: destroy all enemy bullets and clear enemies in view
	var enemy_bullets = get_tree().get_nodes_in_group("enemy_bullets")
	for b in enemy_bullets:
		b.queue_free()
		
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e.is_in_group("boss"):
			e.take_damage(120)
		elif e.has_method("destroy"):
			e.destroy()
			
	var obstacles = get_tree().get_nodes_in_group("obstacles")
	for obs in obstacles:
		if obs.has_method("destroy"):
			obs.destroy()
			
	# Spawn shockwave explosion at center
	if explosion_scene != null:
		var expl = explosion_scene.instantiate()
		get_parent().add_child(expl)
		expl.global_position = global_position
		if expl.has_method("set_explosion_type"):
			expl.set_explosion_type("large")

func activate_shield(duration: float) -> void:
	is_shield_active = true
	shield_timer = duration
	if shield_sprite != null:
		shield_sprite.visible = true
	AudioManager.play_sound("shield_activate")
	emit_signal("shield_changed", true, duration)

func deactivate_shield() -> void:
	is_shield_active = false
	shield_timer = 0.0
	if shield_sprite != null:
		shield_sprite.visible = false
	emit_signal("shield_changed", false, 0.0)

func take_damage() -> void:
	if invulnerable_timer > 0.0:
		return
		
	if is_shield_active:
		deactivate_shield()
		invulnerable_timer = 0.9
		AudioManager.play_sound("shield_hit")
		return
		
	health -= 1
	invulnerable_timer = 0.8
	ScoreManager.reset_combo()
	AudioManager.play_sound("player_hit")
	emit_signal("health_changed", health, max_health)
	
	# Screen shake on damage
	var cams = get_tree().get_nodes_in_group("camera")
	if cams.size() > 0 and cams[0].has_method("shake"):
		cams[0].shake(0.35, 9.0)
		
	if health <= 0:
		die()

func die() -> void:
	visible = false
	set_physics_process(false)
	
	if explosion_scene != null:
		var expl = explosion_scene.instantiate()
		get_parent().add_child(expl)
		expl.global_position = global_position
		if expl.has_method("set_explosion_type"):
			expl.set_explosion_type("large")
			
	# Dramatic camera shake
	var cams = get_tree().get_nodes_in_group("camera")
	if cams.size() > 0 and cams[0].has_method("shake"):
		cams[0].shake(0.6, 16.0)
		
	emit_signal("player_died")
	GameManager.trigger_game_over()

func apply_powerup(type: String, duration: float) -> void:
	active_powerup_type = type
	powerup_timer = duration
	match type:
		"rapid_fire":
			rapid_fire_active = true
		"triple_shot":
			triple_shot_active = true
		"shield":
			activate_shield(duration)
		"health":
			health = mini(health + 1, max_health)
			emit_signal("health_changed", health, max_health)
		"overdrive":
			overdrive_active = true
			rapid_fire_active = true
		"multiplier":
			ScoreManager.combo_multiplier = mini(ScoreManager.combo_multiplier + 1, 5)

func reset_powerups() -> void:
	rapid_fire_active = false
	triple_shot_active = false
	overdrive_active = false
	active_powerup_type = ""
