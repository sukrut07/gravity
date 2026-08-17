class_name KeyboardInput
extends RefCounted

func get_move_vector() -> Vector2:
	var vec = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		vec.y -= 1.0
	if Input.is_action_pressed("move_down"):
		vec.y += 1.0
	if Input.is_action_pressed("move_left"):
		vec.x -= 1.0
	if Input.is_action_pressed("move_right"):
		vec.x += 1.0
	return vec.normalized() if vec.length() > 0.0 else Vector2.ZERO

func is_shooting() -> bool:
	return Input.is_action_pressed("shoot")

func is_shield_active() -> bool:
	return Input.is_action_pressed("shield")

func is_special_triggered() -> bool:
	return Input.is_action_just_pressed("special")

func is_pause_triggered() -> bool:
	return Input.is_action_just_pressed("pause")
