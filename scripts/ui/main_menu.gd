class_name MainMenu
extends Control

## Polished arcade sci-fi startup and main menu for Gravity: Endless Flight.

@onready var play_button: Button = $Content/Buttons/PlayButton
@onready var how_to_play_button: Button = $Content/Buttons/HowToPlayButton
@onready var settings_button: Button = $Content/Buttons/SettingsButton
@onready var quit_button: Button = $Content/Buttons/QuitButton

@onready var records_label: Label = $Content/RecordsLabel
@onready var decorative_ship: Node2D = $DecorativeShip
@onready var how_to_play_modal: CanvasLayer = $HowToPlayModal
@onready var settings_modal: CanvasLayer = $SettingsMenu

var ship_target_y: float = 360.0
var time_passed: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.change_state(GameManager.GameState.MENU)
	
	play_button.pressed.connect(_on_play_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	$HowToPlayModal/PanelContainer/MarginContainer/VBox/CloseButton.pressed.connect(_on_close_instructions)
	how_to_play_modal.visible = false
	
	update_records_display()
	SaveManager.records_updated.connect(func(_s, _d, _c): update_records_display())

func _process(delta: float) -> void:
	time_passed += delta
	# Bob and drift decorative player ship in background
	if decorative_ship != null:
		decorative_ship.position.y = 360.0 + sin(time_passed * 1.8) * 35.0
		decorative_ship.position.x = 220.0 + sin(time_passed * 0.9) * 20.0

func update_records_display() -> void:
	if records_label != null:
		if SaveManager.best_score > 0:
			records_label.text = "RECORD: %d PTS   •   BEST DISTANCE: %d m" % [SaveManager.best_score, int(SaveManager.best_distance)]
		else:
			records_label.text = "WELCOME PILOT — PREPARE FOR LAUNCH"

func _on_play_pressed() -> void:
	AudioManager.play_sound("button_click")
	# Animate ship launching forward
	if decorative_ship != null:
		var tween = create_tween()
		tween.tween_property(decorative_ship, "position:x", 1400.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await tween.finished
	
	GameManager.start_game()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_how_to_play_pressed() -> void:
	AudioManager.play_sound("button_click")
	how_to_play_modal.visible = true

func _on_close_instructions() -> void:
	AudioManager.play_sound("button_click")
	how_to_play_modal.visible = false

func _on_settings_pressed() -> void:
	AudioManager.play_sound("button_click")
	if settings_modal != null:
		settings_modal.open()

func _on_quit_pressed() -> void:
	AudioManager.play_sound("button_click")
	get_tree().quit()
