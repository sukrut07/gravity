class_name LevelIntro
extends CanvasLayer

@onready var start_button: Button = $Panel/VBox/StartButton

func _ready() -> void:
	visible = true
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	visible = false
	GameManager.start_game()
