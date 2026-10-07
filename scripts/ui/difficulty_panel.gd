class_name DifficultyPanel
extends PanelContainer

## Polished Difficulty Adjustment Panel for Gravity: Endless Flight.
## Provides HSlider with 4 discrete states (EASY, NORMAL, HARD, EXTREME),
## live dynamic labels, stat pips, and enemy fleet preview silhouettes.

@onready var slider: HSlider = $MarginContainer/VBox/SliderContainer/HSlider
@onready var difficulty_label: Label = $MarginContainer/VBox/HeaderBox/DifficultyLabel
@onready var description_label: Label = $MarginContainer/VBox/DescriptionLabel
@onready var stats_label: Label = $MarginContainer/VBox/StatsContainer/StatsLabel
@onready var preview_ships_container: HBoxContainer = $MarginContainer/VBox/PreviewContainer/ShipsBox

const DIFFICULTY_COLORS: Array[Color] = [
	Color(0.2, 0.95, 0.4, 1.0),   # EASY - Emerald Green
	Color(0.2, 0.85, 1.0, 1.0),   # NORMAL - Cyan
	Color(1.0, 0.65, 0.1, 1.0),   # HARD - Warning Orange
	Color(1.0, 0.25, 0.25, 1.0),  # EXTREME - Crimson Red
]

const STAT_PIPS: Array[String] = [
	# EASY
	"ENEMIES: █░░░░   SPEED: ██░░░   HAZARDS: █░░░░   SPAWN: ██░░░",
	# NORMAL
	"ENEMIES: ██░░░   SPEED: ███░░   HAZARDS: ██░░░   SPAWN: ███░░",
	# HARD
	"ENEMIES: ████░   SPEED: ████░   HAZARDS: ████░   SPAWN: ████░",
	# EXTREME
	"ENEMIES: █████   SPEED: █████   HAZARDS: █████   SPAWN: █████",
]

func _ready() -> void:
	if slider != null:
		slider.min_value = 0.0
		slider.max_value = 3.0
		slider.step = 1.0
		slider.value = float(DifficultyManager.get_difficulty())
		slider.value_changed.connect(_on_slider_value_changed)
	
	_update_ui_state(DifficultyManager.get_difficulty())

func sync_from_manager() -> void:
	var diff_idx = DifficultyManager.get_difficulty()
	if slider != null and not is_equal_approx(slider.value, float(diff_idx)):
		slider.value = float(diff_idx)
	_update_ui_state(diff_idx)

func _on_slider_value_changed(val: float) -> void:
	var diff_idx = clampi(int(round(val)), 0, 3)
	DifficultyManager.set_difficulty(diff_idx)
	if SaveManager.has_method("set_difficulty_preference"):
		SaveManager.set_difficulty_preference(diff_idx)
	AudioManager.play_sound("button_click")
	_update_ui_state(diff_idx)

func _update_ui_state(diff_idx: int) -> void:
	if difficulty_label != null:
		difficulty_label.text = DifficultyManager.get_difficulty_name()
		difficulty_label.add_theme_color_override("font_color", DIFFICULTY_COLORS[diff_idx])
	
	if description_label != null:
		description_label.text = DifficultyManager.get_difficulty_description()
	
	if stats_label != null:
		stats_label.text = STAT_PIPS[diff_idx]
		stats_label.add_theme_color_override("font_color", DIFFICULTY_COLORS[diff_idx].lerp(Color.WHITE, 0.4))
	
	_update_fleet_preview(diff_idx)

func _update_fleet_preview(diff_idx: int) -> void:
	if preview_ships_container == null:
		return
	
	# Number of preview ships: EASY=2, NORMAL=4, HARD=6, EXTREME=8
	var ship_counts = [2, 4, 6, 8]
	var count = ship_counts[diff_idx]
	var children = preview_ships_container.get_children()
	
	for i in range(children.size()):
		var ship_rect = children[i] as Control
		if ship_rect != null:
			var is_active = (i < count)
			ship_rect.visible = is_active
			if is_active:
				ship_rect.modulate = DIFFICULTY_COLORS[diff_idx]
				# Pulsing preview micro-animation on change
				ship_rect.scale = Vector2(0.7, 0.7)
				var tween = create_tween()
				tween.tween_property(ship_rect, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
