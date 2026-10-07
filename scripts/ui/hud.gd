class_name HUD
extends CanvasLayer

## High-polish arcade HUD for Gravity: Endless Flight.
## Displays score, combo badges, distance, health hearts, powerups, and special meter.

@onready var score_label: Label = $TopLeft/ScoreLabel
@onready var combo_label: Label = $TopLeft/ComboLabel

@onready var distance_label: Label = $TopCenter/DistanceLabel
@onready var sector_label: Label = $TopCenter/SectorLabel

@onready var health_label: Label = $TopRight/HealthLabel
@onready var shield_label: Label = $TopRight/ShieldLabel

@onready var powerups_label: Label = $BottomLeft/PowerupsLabel
@onready var special_label: Label = $BottomRight/SpecialLabel

@onready var announcement_label: Label = $AnnouncementContainer/AnnouncementLabel
@onready var controls_hint: Label = $ControlsHint

var announcement_timer: float = 0.0
var hint_timer: float = 5.0

func _ready() -> void:
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.combo_changed.connect(_on_combo_changed)
	GameManager.distance_updated.connect(_on_distance_updated)
	GameManager.special_energy_updated.connect(_on_special_energy_updated)
	DifficultyManager.tier_changed.connect(_on_tier_changed)
	DifficultyManager.milestone_reached.connect(_on_milestone_reached)
	DifficultyManager.event_started.connect(_on_event_started)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		if p.has_signal("health_changed"):
			p.health_changed.connect(_on_health_changed)
		if p.has_signal("shield_changed"):
			p.shield_changed.connect(_on_shield_changed)
			
	announcement_label.visible = false
	
	_on_score_changed(ScoreManager.score)
	_on_combo_changed(ScoreManager.combo_multiplier, 0.0)
	_on_distance_updated(GameManager.distance_meters)
	_on_special_energy_updated(GameManager.special_energy, GameManager.MAX_SPECIAL_ENERGY, GameManager.is_special_ready())
	_on_tier_changed(DifficultyManager.current_tier)
	_on_health_changed(5, 5)

	# Desktop keyboard controls hint
	if controls_hint != null:
		controls_hint.text = "W / S — MOVE  •  SPACE — FIRE  •  SHIFT — SHIELD  •  E — SPECIAL"

	# Run start difficulty announcement banner
	var diff_name = DifficultyManager.get_difficulty_name()
	var diff_idx = DifficultyManager.get_difficulty()
	var diff_colors = [
		Color(0.2, 0.95, 0.4),  # EASY
		Color(0.2, 0.85, 1.0),  # NORMAL
		Color(1.0, 0.65, 0.1),  # HARD
		Color(1.0, 0.25, 0.25), # EXTREME
	]
	show_announcement("%s RUN" % diff_name, diff_colors[diff_idx], 3.0)

func _process(delta: float) -> void:
	if announcement_timer > 0.0:
		announcement_timer -= delta
		if announcement_timer <= 0.0:
			announcement_label.visible = false
			
	if hint_timer > 0.0:
		hint_timer -= delta
		if hint_timer <= 0.0 and controls_hint != null:
			var tween = create_tween()
			tween.tween_property(controls_hint, "modulate:a", 0.0, 0.8)
			
	# Update active powerups label from player state
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		if p.powerup_timer > 0.0 and p.active_powerup_type != "":
			var p_name = p.active_powerup_type.replace("_", " ").to_upper()
			powerups_label.text = "ACTIVE: %s (%.1fs)" % [p_name, p.powerup_timer]
			powerups_label.visible = true
		else:
			powerups_label.visible = false

func _on_score_changed(score_val: int) -> void:
	score_label.text = "SCORE: %06d" % score_val

func _on_combo_changed(mult: int, timer_ratio: float) -> void:
	if mult > 1:
		combo_label.text = "COMBO x%d" % mult
		combo_label.visible = true
		if mult >= 5:
			combo_label.modulate = Color(1.0, 0.2, 0.2, 1.0) # Fiery red max combo
			combo_label.scale = Vector2(1.2, 1.2)
		elif mult >= 3:
			combo_label.modulate = Color(1.0, 0.8, 0.1, 1.0) # Gold combo
			combo_label.scale = Vector2(1.1, 1.1)
		else:
			combo_label.modulate = Color(0.2, 0.9, 1.0, 1.0) # Cyan combo
			combo_label.scale = Vector2(1.0, 1.0)
	else:
		combo_label.visible = false

func _on_distance_updated(dist_m: float) -> void:
	distance_label.text = "%d m" % int(dist_m)

func _on_tier_changed(tier_name: String) -> void:
	sector_label.text = tier_name

func _on_health_changed(current_hp: int, max_hp: int) -> void:
	var hearts_str = ""
	for i in range(max_hp):
		if i < current_hp:
			hearts_str += "♥ "
		else:
			hearts_str += "♡ "
	health_label.text = "HULL: " + hearts_str.strip_edges()
	
	if current_hp <= 1:
		health_label.modulate = Color(1.0, 0.2, 0.2, 1.0)
	elif current_hp <= 2:
		health_label.modulate = Color(1.0, 0.6, 0.1, 1.0)
	else:
		health_label.modulate = Color(0.2, 0.95, 0.4, 1.0)

func _on_shield_changed(is_active: bool, duration: float) -> void:
	if is_active:
		shield_label.text = "SHIELD: ACTIVE (%.1fs)" % duration
		shield_label.modulate = Color(0.2, 0.8, 1.0, 1.0)
	else:
		shield_label.text = "SHIELD: [SHIFT]"
		shield_label.modulate = Color(0.7, 0.7, 0.8, 0.8)

func _on_special_energy_updated(current: float, max_energy: float, is_ready: bool) -> void:
	var pct = int((current / max_energy) * 100)
	if is_ready:
		special_label.text = "[E] SCREEN BURST: READY!"
		special_label.modulate = Color(1.0, 0.9, 0.2, 1.0)
	else:
		var bars_total = 10
		var filled = int((current / max_energy) * bars_total)
		var bar_str = ""
		for i in range(bars_total):
			bar_str += "█" if i < filled else "░"
		special_label.text = "SPECIAL [%s] %d%%" % [bar_str, pct]
		special_label.modulate = Color(0.7, 0.7, 0.8, 0.85)

func _on_milestone_reached(_dist: float, title: String) -> void:
	show_announcement(title, Color(0.2, 0.9, 1.0), 3.0)

func _on_event_started(_event_name: String, banner: String) -> void:
	show_announcement(banner, Color(1.0, 0.3, 0.3), 3.5)

func show_announcement(text: String, col: Color, duration: float) -> void:
	announcement_label.text = text
	announcement_label.modulate = col
	announcement_label.visible = true
	announcement_timer = duration
	
	# Scale punch animation
	announcement_label.scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.tween_property(announcement_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
