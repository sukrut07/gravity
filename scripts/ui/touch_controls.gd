class_name TouchControls
extends CanvasLayer

## Mobile Virtual Touch Controls for Gravity: Endless Flight.
## Provides virtual joystick (bottom-left) and action buttons (bottom-right: FIRE, SHIELD, SPECIAL, PAUSE).
## Supports simultaneous multi-touch, deadzone damping, and platform-aware auto-visibility.

# Node References
@onready var root_control: Control = $Control
@onready var joystick_base: Control = $Control/JoystickContainer/JoystickBase
@onready var joystick_knob: Control = $Control/JoystickContainer/JoystickBase/Knob

@onready var fire_btn: Control = $Control/ActionButtons/FireButton
@onready var shield_btn: Control = $Control/ActionButtons/ShieldButton
@onready var special_btn: Control = $Control/ActionButtons/SpecialButton
@onready var pause_btn: Control = $Control/TopRightMargin/PauseButton

# Joystick Parameters
const JOYSTICK_MAX_RADIUS: float = 55.0
const JOYSTICK_DEADZONE: float = 0.10

var joystick_touch_id: int = -1
var joystick_center: Vector2 = Vector2.ZERO

# Button Touch IDs for independent multi-touch
var fire_touch_id: int = -1
var shield_touch_id: int = -1
var special_touch_id: int = -1
var pause_touch_id: int = -1

func _ready() -> void:
	add_to_group("touch_controls")
	refresh_visibility()
	
	# Connect to special energy updates for visual feedback
	GameManager.special_energy_updated.connect(_on_special_energy_updated)

func refresh_visibility() -> void:
	var show_touch = InputManager.should_show_touch_controls()
	visible = show_touch
	set_process_input(show_touch)

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Check Joystick
		if joystick_touch_id == -1 and joystick_base != null and _is_point_in_control(event.position, joystick_base):
			joystick_touch_id = event.index
			_update_joystick(event.position)
			return

		# Check Fire Button (Hold to fire)
		if fire_touch_id == -1 and fire_btn != null and _is_point_in_control(event.position, fire_btn):
			fire_touch_id = event.index
			InputManager.set_touch_shooting(true)
			_animate_press(fire_btn, true)
			return

		# Check Shield Button (Tap)
		if shield_touch_id == -1 and shield_btn != null and _is_point_in_control(event.position, shield_btn):
			shield_touch_id = event.index
			InputManager.trigger_shield()
			_animate_press(shield_btn, true)
			return

		# Check Special Button (Tap)
		if special_touch_id == -1 and special_btn != null and _is_point_in_control(event.position, special_btn):
			special_touch_id = event.index
			InputManager.trigger_special()
			_animate_press(special_btn, true)
			return

		# Check Pause Button (Tap)
		if pause_touch_id == -1 and pause_btn != null and _is_point_in_control(event.position, pause_btn):
			pause_touch_id = event.index
			InputManager.trigger_pause()
			_animate_press(pause_btn, true)
			return

	else: # Touch Released
		if event.index == joystick_touch_id:
			joystick_touch_id = -1
			_reset_joystick()
		elif event.index == fire_touch_id:
			fire_touch_id = -1
			InputManager.set_touch_shooting(false)
			_animate_press(fire_btn, false)
		elif event.index == shield_touch_id:
			shield_touch_id = -1
			_animate_press(shield_btn, false)
		elif event.index == special_touch_id:
			special_touch_id = -1
			_animate_press(special_btn, false)
		elif event.index == pause_touch_id:
			pause_touch_id = -1
			_animate_press(pause_btn, false)

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == joystick_touch_id:
		_update_joystick(event.position)

func _update_joystick(touch_pos: Vector2) -> void:
	if joystick_base == null or joystick_knob == null:
		return

	var center = joystick_base.global_position + (joystick_base.size * 0.5)
	var offset = touch_pos - center
	var dist = offset.length()
	
	var clamped_dist = minf(dist, JOYSTICK_MAX_RADIUS)
	var dir = offset.normalized() if dist > 0.001 else Vector2.ZERO
	
	# Move knob visually
	joystick_knob.position = (joystick_base.size * 0.5) + (dir * clamped_dist) - (joystick_knob.size * 0.5)
	
	# Deadzone normalization
	var norm_strength = clamped_dist / JOYSTICK_MAX_RADIUS
	if norm_strength < JOYSTICK_DEADZONE:
		InputManager.set_touch_move(Vector2.ZERO)
	else:
		# Remap [deadzone, 1.0] -> [0.0, 1.0]
		var remapped = (norm_strength - JOYSTICK_DEADZONE) / (1.0 - JOYSTICK_DEADZONE)
		InputManager.set_touch_move(dir * remapped)

func _reset_joystick() -> void:
	if joystick_base != null and joystick_knob != null:
		joystick_knob.position = (joystick_base.size * 0.5) - (joystick_knob.size * 0.5)
	InputManager.set_touch_move(Vector2.ZERO)

func _is_point_in_control(point: Vector2, ctrl: Control) -> bool:
	if ctrl == null or not ctrl.is_visible_in_tree():
		return false
	var rect = Rect2(ctrl.global_position, ctrl.size)
	# Generous 12px touch padding for comfortable ergonomics
	return rect.grow(12.0).has_point(point)

func _animate_press(ctrl: Control, pressed: bool) -> void:
	if ctrl == null:
		return
	var target_scale = Vector2(0.92, 0.92) if pressed else Vector2(1.0, 1.0)
	var tween = create_tween()
	tween.tween_property(ctrl, "scale", target_scale, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_special_energy_updated(_cur: float, _max: float, is_ready: bool) -> void:
	if special_btn != null:
		# Glow golden when charged, subtle dim when uncharged
		special_btn.modulate = Color(1.0, 0.9, 0.2, 1.0) if is_ready else Color(0.7, 0.7, 0.8, 0.65)
