class_name HUD
extends CanvasLayer

@onready var score_label: Label = $TopLeft/ScoreLabel
@onready var destroyed_label: Label = $TopLeft/DestroyedLabel
@onready var multiplier_label: Label = $TopLeft/MultiplierLabel
@onready var distance_label: Label = $TopCenter/DistanceLabel
@onready var health_label: Label = $TopRight/HealthLabel
@onready var gesture_label: Label = $BottomRight/GestureLabel
@onready var milestone_label: Label = $MilestoneNotification
@onready var section_prompt_label: Label = $SectionPrompt
@onready var debug_overlay: PanelContainer = $DebugOverlay
@onready var debug_info_label: Label = $DebugOverlay/DebugInfoLabel

var milestone_timer: float = 0.0
var section_prompt_timer: float = 0.0
var player_input_mgr: InputManager = null

func _ready() -> void:
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.distance_updated.connect(_on_distance_updated)
	GameManager.destroyed_count_updated.connect(_on_destroyed_updated)
	GameManager.milestone_reached.connect(_on_milestone_reached)
	GameManager.section_changed.connect(_on_section_changed)
	
	milestone_label.visible = false
	section_prompt_label.visible = false
	debug_overlay.visible = false
	
	_on_score_updated(GameManager.score, GameManager.score_multiplier)
	_on_distance_updated(GameManager.distance_meters)
	_on_destroyed_updated(GameManager.destroyed_count)

func _process(delta: float) -> void:
	if milestone_timer > 0.0:
		milestone_timer -= delta
		if milestone_timer <= 0.0:
			milestone_label.visible = false

	if section_prompt_timer > 0.0:
		section_prompt_timer -= delta
		if section_prompt_timer <= 0.0:
			section_prompt_label.visible = false

	# Lazy find Player InputManager
	if player_input_mgr == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_input_mgr = players[0].get_node_or_null("InputManager")

	# Update bottom-right Gesture Connection Status
	if player_input_mgr != null and player_input_mgr.is_gesture_active():
		var g_name = player_input_mgr.get_gesture_name()
		var conf = int(player_input_mgr.get_confidence() * 100)
		gesture_label.text = "GESTURE: CONNECTED (%s %d%%)" % [g_name, conf]
		gesture_label.modulate = Color(0.2, 0.9, 0.4, 1.0)
	else:
		gesture_label.text = "GESTURE: DISCONNECTED (KEYBOARD MODE)"
		gesture_label.modulate = Color(0.7, 0.7, 0.7, 0.8)

	# Handle F3 Debug Overlay Toggle
	if Input.is_key_pressed(KEY_F3):
		if not Input.is_action_just_pressed("ui_focus_next"):
			# debounced toggle
			pass

	if Input.is_action_just_pressed("ui_focus_next") or Input.is_physical_key_pressed(KEY_F3):
		# Toggle on press
		pass

	if debug_overlay.visible:
		var fps = Engine.get_frames_per_second()
		var is_conn = player_input_mgr != null and player_input_mgr.is_gesture_active()
		var g_name = player_input_mgr.get_gesture_name() if player_input_mgr else "N/A"
		var conf = int((player_input_mgr.get_confidence() if player_input_mgr else 0.0) * 100)
		var move_y = player_input_mgr.get_move_y() if player_input_mgr else 0.0
		var shooting = player_input_mgr.is_shooting() if player_input_mgr else false
		var shielding = player_input_mgr.is_shield_active() if player_input_mgr else false
		var move_str = "UP" if move_y < -0.1 else ("DOWN" if move_y > 0.1 else "NEUTRAL")

		debug_info_label.text = "FPS: %d\nHAND: %s\nGESTURE: %s\nCONFIDENCE: %d%%\nMOVE: %s (%.2f)\nSHOOT: %s\nSHIELD: %s" % [
			fps,
			"CONNECTED" if is_conn else "DISCONNECTED",
			g_name,
			conf,
			move_str,
			move_y,
			"YES" if shooting else "NO",
			"YES" if shielding else "NO"
		]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			debug_overlay.visible = not debug_overlay.visible

func _on_score_updated(score: int, multiplier: int) -> void:
	score_label.text = "SCORE: %06d" % score
	multiplier_label.text = "MULTIPLIER: x%d" % multiplier

func _on_distance_updated(dist_m: float) -> void:
	distance_label.text = "DISTANCE: %04d / 3000 m" % int(dist_m)

func _on_destroyed_updated(count: int) -> void:
	destroyed_label.text = "DESTROYED: %03d" % count

func _on_milestone_reached(dist_m: float, title: String) -> void:
	milestone_label.text = "%s — %d METERS" % [title, int(dist_m)]
	milestone_label.visible = true
	milestone_timer = 3.0

func _on_section_changed(section_name: String, prompt_text: String) -> void:
	milestone_label.text = section_name
	milestone_label.visible = true
	milestone_timer = 3.5
	
	section_prompt_label.text = prompt_text
	section_prompt_label.visible = true
	section_prompt_timer = 4.5
