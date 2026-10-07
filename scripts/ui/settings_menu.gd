class_name SettingsMenu
extends CanvasLayer

## Settings menu modal for audio, screen shake, and display options.

@onready var sfx_slider: HSlider = $PanelContainer/MarginContainer/VBox/SFXContainer/SFXSlider
@onready var music_slider: HSlider = $PanelContainer/MarginContainer/VBox/MusicContainer/MusicSlider
@onready var shake_check: CheckBox = $PanelContainer/MarginContainer/VBox/ShakeCheck
@onready var fullscreen_check: CheckBox = $PanelContainer/MarginContainer/VBox/FullscreenCheck
@onready var close_button: Button = $PanelContainer/MarginContainer/VBox/CloseButton
@onready var difficulty_panel: Control = get_node_or_null("PanelContainer/MarginContainer/VBox/DifficultyPanel")

signal closed()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	sfx_slider.value = SaveManager.sfx_volume
	music_slider.value = SaveManager.music_volume
	shake_check.button_pressed = SaveManager.screen_shake_enabled
	fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	sfx_slider.value_changed.connect(_on_sfx_changed)
	music_slider.value_changed.connect(_on_music_changed)
	shake_check.toggled.connect(_on_shake_toggled)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	close_button.pressed.connect(_on_close_pressed)

func open() -> void:
	visible = true
	sfx_slider.value = SaveManager.sfx_volume
	music_slider.value = SaveManager.music_volume
	shake_check.button_pressed = SaveManager.screen_shake_enabled
	if difficulty_panel != null and difficulty_panel.has_method("sync_from_manager"):
		difficulty_panel.sync_from_manager()

func close() -> void:
	visible = false
	SaveManager.save_data()
	emit_signal("closed")

func _on_sfx_changed(val: float) -> void:
	SaveManager.sfx_volume = val
	AudioManager.play_sound("button_click")

func _on_music_changed(val: float) -> void:
	SaveManager.music_volume = val

func _on_shake_toggled(pressed: bool) -> void:
	SaveManager.screen_shake_enabled = pressed
	AudioManager.play_sound("button_click")

func _on_fullscreen_toggled(pressed: bool) -> void:
	SaveManager.fullscreen_enabled = pressed
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	AudioManager.play_sound("button_click")

func _on_close_pressed() -> void:
	AudioManager.play_sound("button_click")
	close()
