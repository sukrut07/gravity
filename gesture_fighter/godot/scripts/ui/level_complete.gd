class_name LevelComplete
extends CanvasLayer

@onready var final_score_label: Label = $Panel/VBox/FinalScoreLabel
@onready var final_distance_label: Label = $Panel/VBox/FinalDistanceLabel
@onready var final_destroyed_label: Label = $Panel/VBox/FinalDestroyedLabel
@onready var powerups_label: Label = $Panel/VBox/PowerupsLabel
@onready var accuracy_label: Label = $Panel/VBox/AccuracyLabel
@onready var replay_button: Button = $Panel/VBox/ReplayButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

func _ready() -> void:
	visible = false
	GameManager.state_changed.connect(_on_state_changed)
	replay_button.pressed.connect(_on_replay_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_state_changed(old_state: GameManager.GameState, new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.LEVEL_COMPLETE:
		visible = true
		final_score_label.text = "FINAL SCORE: %06d" % GameManager.score
		final_distance_label.text = "DISTANCE: %04d m" % int(GameManager.distance_meters)
		final_destroyed_label.text = "ENEMIES DESTROYED: %03d" % GameManager.destroyed_count
		powerups_label.text = "POWERUPS COLLECTED: %d" % GameManager.powerups_collected
		accuracy_label.text = "CANNON ACCURACY: %.1f%%" % GameManager.get_accuracy_percent()
	else:
		visible = false

func _on_replay_pressed() -> void:
	visible = false
	GameManager.start_game()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
