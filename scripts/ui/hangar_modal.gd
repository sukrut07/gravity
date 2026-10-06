class_name HangarModal
extends CanvasLayer

## Interactive spaceship selection and hangar preview for Gravity: Endless Flight.

signal ship_equipped(ship_index: int)

@onready var ship_name_label: Label = $PanelContainer/MarginContainer/VBox/ShipInfo/NameLabel
@onready var ship_role_label: Label = $PanelContainer/MarginContainer/VBox/ShipInfo/RoleLabel
@onready var ship_desc_label: Label = $PanelContainer/MarginContainer/VBox/ShipInfo/DescLabel

@onready var speed_bar: ProgressBar = $PanelContainer/MarginContainer/VBox/StatsGrid/SpeedBar
@onready var handling_bar: ProgressBar = $PanelContainer/MarginContainer/VBox/StatsGrid/HandlingBar
@onready var firepower_bar: ProgressBar = $PanelContainer/MarginContainer/VBox/StatsGrid/FirepowerBar
@onready var shield_bar: ProgressBar = $PanelContainer/MarginContainer/VBox/StatsGrid/ShieldBar

@onready var preview_anim_sprite: AnimatedSprite2D = $PanelContainer/MarginContainer/VBox/PreviewContainer/ShipPreview/AnimatedSprite2D
@onready var preview_exhaust: AnimatedSprite2D = $PanelContainer/MarginContainer/VBox/PreviewContainer/ShipPreview/EngineExhaust
@onready var preview_particles: CPUParticles2D = $PanelContainer/MarginContainer/VBox/PreviewContainer/ShipPreview/EngineParticles

@onready var prev_button: Button = $PanelContainer/MarginContainer/VBox/PreviewContainer/PrevButton
@onready var next_button: Button = $PanelContainer/MarginContainer/VBox/PreviewContainer/NextButton
@onready var equip_button: Button = $PanelContainer/MarginContainer/VBox/BottomRow/EquipButton
@onready var close_button: Button = $PanelContainer/MarginContainer/VBox/BottomRow/CloseButton

@onready var tabs_container: HBoxContainer = $PanelContainer/MarginContainer/VBox/ShipTabsContainer

var current_preview_index: int = 0
var anim_time: float = 0.0
var tab_buttons: Array[Button] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	current_preview_index = SaveManager.selected_ship_index
	_build_ship_tabs()
	
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	equip_button.pressed.connect(_on_equip_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _process(delta: float) -> void:
	if not visible:
		return
		
	anim_time += delta
	# Floating ship bobbing and dynamic banking cycle
	var preview_node = get_node_or_null("PanelContainer/MarginContainer/VBox/PreviewContainer/ShipPreview")
	if preview_node != null:
		preview_node.position.y = 80.0 + sin(anim_time * 2.2) * 14.0
		var bank_cycle = sin(anim_time * 1.5)
		preview_node.rotation = bank_cycle * deg_to_rad(9.0)
		
		if preview_anim_sprite != null:
			if bank_cycle < -0.55:
				preview_anim_sprite.animation = "up_2"
			elif bank_cycle < -0.15:
				preview_anim_sprite.animation = "up_1"
			elif bank_cycle > 0.55:
				preview_anim_sprite.animation = "down_2"
			elif bank_cycle > 0.15:
				preview_anim_sprite.animation = "down_1"
			else:
				preview_anim_sprite.animation = "straight"

func open() -> void:
	visible = true
	current_preview_index = SaveManager.selected_ship_index
	update_preview()

func close() -> void:
	visible = false

func _build_ship_tabs() -> void:
	tab_buttons.clear()
	for child in tabs_container.get_children():
		child.queue_free()
		
	var all_ships = ShipData.get_all_ships()
	for i in range(all_ships.size()):
		var ship = all_ships[i]
		var btn = Button.new()
		btn.text = ship["name"]
		btn.custom_minimum_size = Vector2(100, 36)
		btn.add_theme_font_size_override("font_size", 12)
		var idx = i
		btn.pressed.connect(func(): _select_tab(idx))
		tabs_container.add_child(btn)
		tab_buttons.append(btn)

func _select_tab(index: int) -> void:
	AudioManager.play_sound("button_click")
	current_preview_index = index
	update_preview()

func update_preview() -> void:
	var ship = ShipData.get_ship(current_preview_index)
	ship_name_label.text = ship["name"]
	ship_name_label.add_theme_color_override("font_color", ship["accent_color"])
	ship_role_label.text = ship["role"]
	ship_desc_label.text = ship["desc"]
	
	speed_bar.value = ship["stat_speed"]
	handling_bar.value = ship["stat_handling"]
	firepower_bar.value = ship["stat_firepower"]
	shield_bar.value = ship["stat_shield"]
	
	if preview_anim_sprite != null:
		preview_anim_sprite.sprite_frames = ShipData.create_sprite_frames_for_ship(ship)
		preview_anim_sprite.animation = "straight"
		preview_anim_sprite.play()
		
	if preview_particles != null:
		preview_particles.color = ship["trail_color"]
		
	# Update tab highlights
	for i in range(tab_buttons.size()):
		var b = tab_buttons[i]
		if i == current_preview_index:
			b.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			b.modulate = Color(0.65, 0.65, 0.75, 0.7)
			
	# Update Equip button state
	if current_preview_index == SaveManager.selected_ship_index:
		equip_button.text = "✓ EQUIPPED"
		equip_button.disabled = true
		equip_button.modulate = Color(0.4, 1.0, 0.6, 1.0)
	else:
		equip_button.text = "DEPLOY THIS SHIP"
		equip_button.disabled = false
		equip_button.modulate = Color(1.0, 0.9, 0.2, 1.0)

func _on_prev_pressed() -> void:
	AudioManager.play_sound("button_click")
	var count = ShipData.get_ship_count()
	current_preview_index = (current_preview_index - 1 + count) % count
	update_preview()

func _on_next_pressed() -> void:
	AudioManager.play_sound("button_click")
	var count = ShipData.get_ship_count()
	current_preview_index = (current_preview_index + 1) % count
	update_preview()

func _on_equip_pressed() -> void:
	AudioManager.play_sound("powerup_pickup")
	SaveManager.set_selected_ship(current_preview_index)
	emit_signal("ship_equipped", current_preview_index)
	update_preview()

func _on_close_pressed() -> void:
	AudioManager.play_sound("button_click")
	close()
