class_name PauseMenu
extends CanvasLayer

@onready var resume_button: Button = $Panel/VBox/ResumeButton
@onready var restart_button: Button = $Panel/VBox/RestartButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

func _ready() -> void:
	visible = false
	GameManager.state_changed.connect(_on_state_changed)
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_state_changed(old_state: GameManager.GameState, new_state: GameManager.GameState) -> void:
	visible = (new_state == GameManager.GameState.PAUSED)

func _on_resume_pressed() -> void:
	GameManager.change_state(GameManager.GameState.PLAYING)

func _on_restart_pressed() -> void:
	GameManager.start_game()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
