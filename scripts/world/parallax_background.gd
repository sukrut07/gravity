class_name StarfieldParallax
extends ParallaxBackground

@export var scroll_speed: float = 150.0

@onready var layer_stars1: ParallaxLayer = $LayerStars1
@onready var layer_stars2: ParallaxLayer = $LayerStars2
@onready var layer_nebula: ParallaxLayer = $LayerNebula

var bg_texture: Texture2D = preload("res://SpaceRage/BG.png")

func _ready() -> void:
	# Base SpaceRage Background Layer
	if layer_nebula != null and bg_texture != null:
		layer_nebula.motion_scale = Vector2(0.12, 1.0)
		# 700 width scaled to 0.9 = 630 width, 800 height * 0.9 = 720 height
		layer_nebula.motion_mirroring = Vector2(630, 0)
		var bg_sprite = Sprite2D.new()
		bg_sprite.texture = bg_texture
		bg_sprite.centered = false
		bg_sprite.scale = Vector2(0.9, 0.9)
		layer_nebula.add_child(bg_sprite)
		
	# High-tech Starfield Parallax Layers overlay
	if layer_stars1 != null:
		setup_star_layer(layer_stars1, 80, 1.5, Color(0.85, 0.95, 1.0, 0.8), 0.35)
	if layer_stars2 != null:
		setup_star_layer(layer_stars2, 35, 2.5, Color(0.4, 0.85, 1.0, 0.95), 0.7)

func _process(delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.PLAYING:
		var current_world_speed = scroll_speed + GameManager.distance_meters * 0.05
		scroll_offset.x -= current_world_speed * delta

func setup_star_layer(layer: ParallaxLayer, star_count: int, star_size: float, color: Color, motion_scale_x: float) -> void:
	layer.motion_scale = Vector2(motion_scale_x, 1.0)
	layer.motion_mirroring = Vector2(1280, 0)
	
	var img = Image.create_empty(1280, 720, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	for i in range(star_count):
		var rx = randi() % 1280
		var ry = randi() % 720
		var sz = int(star_size)
		for x in range(rx, min(rx + sz, 1280)):
			for y in range(ry, min(ry + sz, 720)):
				img.set_pixel(x, y, color)
				
	var tex = ImageTexture.create_from_image(img)
	var sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	layer.add_child(sprite)
