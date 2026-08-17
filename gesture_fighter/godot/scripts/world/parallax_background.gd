class_name StarfieldParallax
extends ParallaxBackground

@export var scroll_speed: float = 150.0

@onready var layer_stars1: ParallaxLayer = $LayerStars1
@onready var layer_stars2: ParallaxLayer = $LayerStars2
@onready var layer_nebula: ParallaxLayer = $LayerNebula

func _ready() -> void:
	# Generate procedural starfield textures
	setup_star_layer(layer_stars1, 100, 1.5, Color(0.8, 0.9, 1.0, 0.7), 0.2)
	setup_star_layer(layer_stars2, 40, 3.0, Color(0.4, 0.8, 1.0, 0.9), 0.5)

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
