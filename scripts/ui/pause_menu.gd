class_name PauseMenu
extends CanvasLayer

## In-game pause menu with resume, restart, settings, and main menu options.

@onready var resume_button: Button = $PanelContainer/MarginContainer/VBox/ResumeButton
@onready var restart_button: Button = $PanelContainer/MarginContainer/VBox/RestartButton
@onready var settings_button: Button = $PanelContainer/MarginContainer/VBox/SettingsButton
@onready var menu_button: Button = $PanelContainer/MarginContainer/VBox/MenuButton
@onready var settings_modal: CanvasLayer = get_node_or_null("SettingsMenu")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	GameManager.state_changed.connect(_on_state_changed)
	
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameManager.current_state == GameManager.GameState.PLAYING or GameManager.current_state == GameManager.GameState.PAUSED:
			GameManager.toggle_pause()
			get_viewport().set_input_as_handled()

func _on_state_changed(_old: GameManager.GameState, new_state: GameManager.GameState) -> void:
	visible = (new_state == GameManager.GameState.PAUSED)

func _on_resume_pressed() -> void:
	AudioManager.play_sound("button_click")
	GameManager.change_state(GameManager.GameState.PLAYING)

func _on_restart_pressed() -> void:
	AudioManager.play_sound("button_click")
	GameManager.start_game()
	get_tree().reload_current_scene()

func _on_settings_pressed() -> void:
	AudioManager.play_sound("button_click")
	if settings_modal != null:
		settings_modal.open()

func _on_menu_pressed() -> void:
	AudioManager.play_sound("button_click")
	GameManager.change_state(GameManager.GameState.MENU)
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
