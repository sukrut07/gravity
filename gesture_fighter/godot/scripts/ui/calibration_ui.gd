class_name CalibrationUI
extends CanvasLayer

@onready var step_label: Label = $Panel/VBox/StepLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var start_button: Button = $Panel/VBox/StartButton
@onready var keyboard_button: Button = $Panel/VBox/KeyboardButton

var current_step: int = 0
var calibration_steps: Array = [
	"SHOW YOUR HAND TO THE CAMERA",
	"MOVE HAND TO THE CENTER",
	"MOVE HAND UP (FLY UP)",
	"MOVE HAND DOWN (FLY DOWN)",
	"EXTEND INDEX FINGER (SHOOT)",
	"MAKE A CLOSED FIST (SHIELD)",
	"OPEN PALM (PAUSE GAME)",
	"CALIBRATION COMPLETE - READY!"
]

func _ready() -> void:
	visible = true
	start_button.pressed.connect(_on_start_pressed)
	keyboard_button.pressed.connect(_on_keyboard_pressed)
	update_step_display()

func update_step_display() -> void:
	step_label.text = calibration_steps[current_step]
	if current_step == calibration_steps.size() - 1:
		status_label.text = "STATUS: GESTURE CONTROL READY"
		start_button.visible = true
	else:
		status_label.text = "STEP %d OF %d" % [current_step + 1, calibration_steps.size() - 1]

func _on_start_pressed() -> void:
	visible = false
	GameManager.start_game()

func _on_keyboard_pressed() -> void:
	GameManager.gesture_mode_enabled = false
	visible = false
	GameManager.start_game()

func advance_step() -> void:
	if current_step < calibration_steps.size() - 1:
		current_step += 1
		update_step_display()
