class_name InputManagerClass
extends Node

## Unified abstract input layer for Gravity: Endless Flight.
## Merges desktop keyboard inputs and direct mobile touchscreen gestures into a single clean API.
## Supports direct one-finger ship drag, multi-touch firing, double-tap shield,
## and simultaneous two-finger special burst.

signal shield_pressed()
signal special_pressed()
signal pause_pressed()
signal touch_mode_detected()

# Direct Touch Tracking State
var primary_touch_id: int = -1
var second_touch_id: int = -1
var is_touch_moving: bool = false
var touch_shooting: bool = false
var is_touch_device_active: bool = false

# Touch Position & Delta Tracking
var last_touch_pos: Vector2 = Vector2.ZERO
var touch_drag_delta: Vector2 = Vector2.ZERO
var touch_start_pos: Vector2 = Vector2.ZERO
var touch_start_time: int = 0

# Gesture Timers (milliseconds)
var last_primary_tap_time: int = 0
var last_primary_tap_pos: Vector2 = Vector2.ZERO
var two_finger_tap_time: int = 0

# Legacy compatibility
var touch_move_vector: Vector2 = Vector2.ZERO
var touch_mode_preference: String = "OFF"
var debug_force_touch: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Check initial mobile indicators
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		is_touch_device_active = true

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		reset_all_touches()

func _unhandled_input(event: InputEvent) -> void:
	# Desktop keyboard action triggers
	if event.is_action_pressed("shield"):
		shield_pressed.emit()
	elif event.is_action_pressed("special"):
		special_pressed.emit()
	elif event.is_action_pressed("pause"):
		pause_pressed.emit()

	# Mobile Direct Touch Events
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if not is_touch_device_active:
		is_touch_device_active = true
		touch_mode_detected.emit()
		
	var current_time: int = Time.get_ticks_msec()
	
	if event.pressed:
		if primary_touch_id == -1:
			# Primary finger: spaceship movement
			primary_touch_id = event.index
			is_touch_moving = true
			last_touch_pos = event.position
			touch_start_pos = event.position
			touch_start_time = current_time
			touch_drag_delta = Vector2.ZERO
			
			# Check Double-Tap gesture -> Shield
			var dt: int = current_time - last_primary_tap_time
			var dist: float = event.position.distance_to(last_primary_tap_pos)
			if last_primary_tap_time > 0 and dt <= 380 and dist < 60.0:
				shield_pressed.emit()
				last_primary_tap_time = 0
			else:
				last_primary_tap_time = current_time
				last_primary_tap_pos = event.position
				
		elif second_touch_id == -1 and event.index != primary_touch_id:
			# Second finger: shooting weapon hold
			second_touch_id = event.index
			touch_shooting = true
			
			# Check Two-Finger simultaneous tap -> Special Screen Burst
			if (current_time - touch_start_time) < 250:
				two_finger_tap_time = current_time
	else:
		# Touch released or cancelled
		if two_finger_tap_time > 0 and (current_time - two_finger_tap_time) < 400:
			special_pressed.emit()
			two_finger_tap_time = 0
			
		if event.index == primary_touch_id:
			primary_touch_id = -1
			is_touch_moving = false
			touch_drag_delta = Vector2.ZERO
			
		elif event.index == second_touch_id:
			second_touch_id = -1
			touch_shooting = false
			
		if event.canceled:
			reset_all_touches()

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == primary_touch_id:
		var delta_movement: Vector2 = event.position - last_touch_pos
		touch_drag_delta += delta_movement
		last_touch_pos = event.position

## Consumes and resets the accumulated touch drag delta since last query
func consume_touch_drag_delta() -> Vector2:
	var delta: Vector2 = touch_drag_delta
	touch_drag_delta = Vector2.ZERO
	return delta

func reset_all_touches() -> void:
	primary_touch_id = -1
	second_touch_id = -1
	is_touch_moving = false
	touch_shooting = false
	touch_drag_delta = Vector2.ZERO
	two_finger_tap_time = 0

## Returns whether pulse cannon firing is currently active (Space held or 2nd finger held)
func is_shooting() -> bool:
	return touch_shooting or Input.is_action_pressed("shoot")

## Returns keyboard movement vector (-1.0 to 1.0)
func get_keyboard_vector() -> Vector2:
	var move_x: float = 0.0
	var move_y: float = 0.0
	if Input.is_action_pressed("move_up"):
		move_y -= 1.0
	if Input.is_action_pressed("move_down"):
		move_y += 1.0
	if Input.is_action_pressed("move_left"):
		move_x -= 1.0
	if Input.is_action_pressed("move_right"):
		move_x += 1.0
	return Vector2(move_x, move_y)

## Backward-compatible helper for movement vector
func get_move_vector() -> Vector2:
	var kb: Vector2 = get_keyboard_vector()
	if kb.length_squared() > 0.001:
		return kb
	if touch_move_vector.length_squared() > 0.001:
		return touch_move_vector
	return Vector2.ZERO

func trigger_shield() -> void:
	shield_pressed.emit()

func trigger_special() -> void:
	special_pressed.emit()

func trigger_pause() -> void:
	pause_pressed.emit()

func should_show_touch_controls() -> bool:
	return false
