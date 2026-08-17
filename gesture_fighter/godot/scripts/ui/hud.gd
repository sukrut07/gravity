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

	# Handle F3 Debug Overlay Toggle
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_key_pressed(KEY_F3):
		debug_overlay.visible = not debug_overlay.visible

	if debug_overlay.visible:
		var fps = Engine.get_frames_per_second()
		var udp_status = "CONNECTED" if GameManager.gesture_mode_enabled else "OFFLINE"
		debug_info_label.text = "FPS: %d\nUDP: %s\nGesture Mode: %s\nDistance: %.1fm" % [
			fps, udp_status, "ACTIVE" if GameManager.gesture_mode_enabled else "OFFLINE", GameManager.distance_meters
		]

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
