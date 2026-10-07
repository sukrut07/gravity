class_name InputManagerClass
extends Node

## Unified abstract input layer for Gravity: Endless Flight.
## Merges keyboard inputs and touch inputs into a single clean API.
## Decouples gameplay entities (Player, PauseMenu) from input hardware.

signal shield_pressed()
signal special_pressed()
signal pause_pressed()

# Touch state set by TouchControls (virtual joystick & action buttons)
var touch_move_vector: Vector2 = Vector2.ZERO
var touch_shooting: bool = false

# Touch control visibility mode: "AUTO", "ON", "OFF"
var touch_mode_preference: String = "OFF"

# Debug toggle: F6 forces touch controls in debug builds
var debug_force_touch: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	# F6 debug toggle
	if OS.is_debug_build() and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F6:
			debug_force_touch = not debug_force_touch
			# Notify touch controls to refresh visibility
			get_tree().call_group("touch_controls", "refresh_visibility")

	# Desktop keyboard action triggers
	if event.is_action_pressed("shield"):
		shield_pressed.emit()
	elif event.is_action_pressed("special"):
		special_pressed.emit()
	elif event.is_action_pressed("pause"):
		pause_pressed.emit()

## Returns the unified movement Vector2 (-1.0 to 1.0 on both axes)
func get_move_vector() -> Vector2:
	# If touch joystick is actively giving input, prioritize it
	if touch_move_vector.length_squared() > 0.001:
		return touch_move_vector
	
	# Fallback to desktop keyboard inputs
	var move_x = 0.0
	var move_y = 0.0
	
	if Input.is_action_pressed("move_up"):
		move_y -= 1.0
	if Input.is_action_pressed("move_down"):
		move_y += 1.0
	if Input.is_action_pressed("move_left"):
		move_x -= 1.0
	if Input.is_action_pressed("move_right"):
		move_x += 1.0
		
	return Vector2(move_x, move_y)

## Returns whether pulse cannon firing is currently active (Space held or Touch Fire held)
func is_shooting() -> bool:
	return touch_shooting or Input.is_action_pressed("shoot")

## Called by TouchControls
func set_touch_move(vec: Vector2) -> void:
	touch_move_vector = vec

func set_touch_shooting(active: bool) -> void:
	touch_shooting = active

func trigger_shield() -> void:
	shield_pressed.emit()

func trigger_special() -> void:
	special_pressed.emit()

func trigger_pause() -> void:
	pause_pressed.emit()

## Determines whether touch controls should be active/visible
func should_show_touch_controls() -> bool:
	if debug_force_touch:
		return true
	
	if touch_mode_preference == "ON":
		return true
	elif touch_mode_preference == "OFF":
		return false
	
	# AUTO mode: only enable on dedicated mobile operating systems
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		return true
		
	return false
