class_name StarfieldParallax
extends ParallaxBackground

## Seamless endless space parallax background system.
## Features layered deep space backdrop, nebula tint shifts, and dual-speed starfields.

@export var base_scroll_speed: float = 120.0

@onready var layer_nebula: ParallaxLayer = get_node_or_null("LayerNebula")
@onready var layer_stars1: ParallaxLayer = get_node_or_null("LayerStars1")
@onready var layer_stars2: ParallaxLayer = get_node_or_null("LayerStars2")

var bg_texture: Texture2D = preload("res://SpaceRage/BG.png")
var bg_sprite: Sprite2D = null

func _ready() -> void:
	# Base SpaceRage deep space layer
	if layer_nebula != null and bg_texture != null:
		layer_nebula.motion_scale = Vector2(0.18, 1.0)
		layer_nebula.motion_mirroring = Vector2(630.0, 0.0)
		bg_sprite = Sprite2D.new()
		bg_sprite.texture = bg_texture
		bg_sprite.centered = false
		bg_sprite.scale = Vector2(0.9, 0.9)
		layer_nebula.add_child(bg_sprite)
		
	# Distant small stars
	if layer_stars1 != null:
		_setup_star_layer(layer_stars1, 90, 1.5, Color(0.85, 0.95, 1.0, 0.75), 0.4)
		
	# Midground brighter, faster stars
	if layer_stars2 != null:
		_setup_star_layer(layer_stars2, 45, 2.5, Color(0.4, 0.85, 1.0, 0.95), 0.75)

func _process(delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.PLAYING:
		var current_speed = base_scroll_speed + (DifficultyManager.world_speed * 0.4)
		scroll_offset.x -= current_speed * delta
		
		# Subtle environmental tint shifting with distance tiers
		if bg_sprite != null:
			var dist = GameManager.distance_meters
			if dist >= 8000.0:
				bg_sprite.modulate = bg_sprite.modulate.lerp(Color(0.8, 0.6, 1.0), delta * 0.5) # Violet void
			elif dist >= 5000.0:
				bg_sprite.modulate = bg_sprite.modulate.lerp(Color(0.7, 0.9, 1.0), delta * 0.5) # Ice blue
			elif dist >= 2500.0:
				bg_sprite.modulate = bg_sprite.modulate.lerp(Color(1.0, 0.8, 0.7), delta * 0.5) # Crimson nebula
			else:
				bg_sprite.modulate = bg_sprite.modulate.lerp(Color.WHITE, delta * 0.5)

func _setup_star_layer(layer: ParallaxLayer, star_count: int, star_size: float, color: Color, motion_scale_x: float) -> void:
	layer.motion_scale = Vector2(motion_scale_x, 1.0)
	layer.motion_mirroring = Vector2(1280.0, 0.0)
	
	var img = Image.create_empty(1280, 720, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var rng = RandomNumberGenerator.new()
	rng.seed = int(motion_scale_x * 1000)
	
	for i in range(star_count):
		var rx = rng.randi() % 1280
		var ry = rng.randi() % 720
		var sz = int(star_size)
		for x in range(rx, mini(rx + sz, 1280)):
			for y in range(ry, mini(ry + sz, 720)):
				img.set_pixel(x, y, color)
				
	var tex = ImageTexture.create_from_image(img)
	var sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	layer.add_child(sprite)
