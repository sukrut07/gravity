class_name CalibrationUI
extends CanvasLayer

@onready var step_label: Label = $Panel/VBox/StepLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var start_button: Button = $Panel/VBox/StartButton
@onready var keyboard_button: Button = $Panel/VBox/KeyboardButton

var current_step: int = 0
var calibration_steps: Array = [
	"GESTURE CONTROL\nSHOW YOUR HAND\nMove your hand to the center",
	"MOVE UP\nMove hand to top zone to fly up",
	"MOVE DOWN\nMove hand to bottom zone to fly down",
	"INDEX FINGER = FIRE\nExtend index finger to shoot cannon",
	"FIST = SHIELD\nMake a closed fist to activate shield",
	"TWO FINGERS = SPECIAL\nShow two fingers for special ability",
	"OPEN PALM = PAUSE\nShow open palm to pause game",
	"GESTURE CONTROL READY"
]

func _ready() -> void:
	visible = true
	start_button.text = "START GAME (GESTURE MODE)"
	keyboard_button.text = "SKIP / KEYBOARD MODE"
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
	GameManager.gesture_mode_enabled = true
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
