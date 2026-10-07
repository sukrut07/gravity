class_name GameOver
extends CanvasLayer

## Polished Game Over screen displaying run statistics and high score records.

@onready var title_label: Label = $PanelContainer/MarginContainer/VBox/TitleLabel
@onready var difficulty_run_label: Label = $PanelContainer/MarginContainer/VBox/DifficultyRunLabel
@onready var high_score_badge: Label = $PanelContainer/MarginContainer/VBox/HighScoreBadge
@onready var final_score_label: Label = $PanelContainer/MarginContainer/VBox/StatsContainer/ScoreLabel
@onready var final_distance_label: Label = $PanelContainer/MarginContainer/VBox/StatsContainer/DistanceLabel
@onready var final_destroyed_label: Label = $PanelContainer/MarginContainer/VBox/StatsContainer/DestroyedLabel
@onready var final_combo_label: Label = $PanelContainer/MarginContainer/VBox/StatsContainer/ComboLabel
@onready var retry_button: Button = $PanelContainer/MarginContainer/VBox/RetryButton
@onready var menu_button: Button = $PanelContainer/MarginContainer/VBox/MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	GameManager.game_over_processed.connect(_on_game_over_processed)
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_game_over_processed(stats: Dictionary) -> void:
	visible = true
	
	if difficulty_run_label != null:
		difficulty_run_label.text = "[%s RUN]" % DifficultyManager.get_difficulty_name()
		var diff_idx = DifficultyManager.get_difficulty()
		var colors = [Color(0.2, 0.95, 0.4), Color(0.2, 0.85, 1.0), Color(1.0, 0.65, 0.1), Color(1.0, 0.25, 0.25)]
		difficulty_run_label.add_theme_color_override("font_color", colors[diff_idx])
	final_score_label.text = "FINAL SCORE: %d" % stats.get("score", 0)
	final_distance_label.text = "DISTANCE: %d m" % int(stats.get("distance", 0.0))
	final_destroyed_label.text = "ENEMIES DESTROYED: %d" % stats.get("enemies_destroyed", 0)
	final_combo_label.text = "MAX COMBO: x%d" % stats.get("max_combo", 1)
	
	if stats.get("is_new_high_score", false):
		high_score_badge.text = "★ NEW HIGH SCORE! ★"
		high_score_badge.visible = true
		high_score_badge.modulate = Color(1.0, 0.85, 0.1, 1.0)
	else:
		high_score_badge.text = "BEST: %d PTS (%d m)" % [stats.get("best_score", 0), int(stats.get("best_distance", 0.0))]
		high_score_badge.visible = true
		high_score_badge.modulate = Color(0.7, 0.8, 1.0, 0.8)

func _on_retry_pressed() -> void:
	AudioManager.play_sound("button_click")
	visible = false
	GameManager.start_game()
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	AudioManager.play_sound("button_click")
	visible = false
	GameManager.change_state(GameManager.GameState.MENU)
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
