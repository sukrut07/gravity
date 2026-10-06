class_name StarfieldParallax
extends ParallaxBackground

## Seamless endless space parallax background system.
## Features multi-tile layered deep space backdrop, nebula tint shifts, and dual-speed starfields.

@export var base_scroll_speed: float = 120.0

@onready var layer_nebula: ParallaxLayer = get_node_or_null("LayerNebula")
@onready var layer_stars1: ParallaxLayer = get_node_or_null("LayerStars1")
@onready var layer_stars2: ParallaxLayer = get_node_or_null("LayerStars2")

var bg_texture: Texture2D = preload("res://SpaceRage/BG.png")
var nebula_sprites: Array[Sprite2D] = []

func _ready() -> void:
	# Ensure deep space dark clear color as foundational safeguard
	RenderingServer.set_default_clear_color(Color(0.04, 0.06, 0.1, 1.0))
	
	# Base SpaceRage deep space layer
	if layer_nebula != null and bg_texture != null:
		layer_nebula.motion_scale = Vector2(0.18, 1.0)
		
		# Scale texture to comfortably cover 720p height with vertical safety margin
		var scale_factor = Vector2(0.95, 0.95)
		var tile_w = 700.0 * scale_factor.x # 665.0 px
		
		# Set motion_mirroring to match the repeating tile width
		layer_nebula.motion_mirroring = Vector2(tile_w, 0.0)
		
		# Spawn 4 contiguous tiles across [0, 2660] px.
		# Viewport is 1280 wide. Even at maximum negative scroll wrap (-665 px),
		# the tiles extend from -665 to 1995 px, 100% covering the 1280 px screen without any seams or gaps!
		for i in range(4):
			var sp = Sprite2D.new()
			sp.texture = bg_texture
			sp.centered = false
			sp.scale = scale_factor
			sp.position = Vector2(i * tile_w, -20.0)
			layer_nebula.add_child(sp)
			nebula_sprites.append(sp)
		
	# Distant small stars (spanned across 2 cycles of 1280 to guarantee full screen coverage while scrolling)
	if layer_stars1 != null:
		_setup_star_layer(layer_stars1, 100, 1.5, Color(0.85, 0.95, 1.0, 0.75), 0.4)
		
	# Midground brighter, faster stars
	if layer_stars2 != null:
		_setup_star_layer(layer_stars2, 50, 2.5, Color(0.4, 0.85, 1.0, 0.95), 0.75)

func _process(delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.PLAYING:
		var current_speed = base_scroll_speed + (DifficultyManager.world_speed * 0.4)
		scroll_offset.x -= current_speed * delta
		
		# Subtle environmental tint shifting with distance tiers across all tiles
		if nebula_sprites.size() > 0:
			var dist = GameManager.distance_meters
			var target_color = Color.WHITE
			if dist >= 8000.0:
				target_color = Color(0.8, 0.6, 1.0) # Violet void
			elif dist >= 5000.0:
				target_color = Color(0.7, 0.9, 1.0) # Ice blue
			elif dist >= 2500.0:
				target_color = Color(1.0, 0.8, 0.7) # Crimson nebula
			
			for sp in nebula_sprites:
				sp.modulate = sp.modulate.lerp(target_color, delta * 0.5)

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
	
	# Add 2 contiguous copies (0 and 1280) so that wrapping at 1280 always covers the 1280 viewport
	for copy_idx in range(2):
		var sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.centered = false
		sprite.position = Vector2(copy_idx * 1280.0, 0.0)
		layer.add_child(sprite)
