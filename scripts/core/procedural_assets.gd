class_name ProceduralAssets
extends Node

## Helper utility that generates clean 2D procedural ImageTextures for all game elements.
## Ensures 100% playable and visually coherent sci-fi visuals without requiring external art.

static func create_player_texture() -> Texture2D:
	var img = Image.create_empty(64, 40, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# Draw sleek futuristic jet facing right
	for x in range(64):
		for y in range(40):
			var ny = abs(y - 20)
			# Main Fuselage triangle
			if x >= 10 and x <= 58:
				var max_h = 16.0 * (1.0 - pow((x - 30.0) / 30.0, 2))
				if ny <= max_h:
					img.set_pixel(x, y, Color(0.12, 0.25, 0.45, 1.0))
			# Cockpit glow
			if x >= 30 and x <= 45 and ny <= 6:
				img.set_pixel(x, y, Color(0.1, 0.85, 1.0, 0.9))
			# Wing swept back
			if x >= 15 and x <= 38:
				var wing_h = (38 - x) * 0.8 + 4
				if ny >= 6 and ny <= wing_h:
					img.set_pixel(x, y, Color(0.08, 0.5, 0.8, 1.0))
			# High-tech cyan edge highlight
			if x == 58 and ny <= 2:
				img.set_pixel(x, y, Color(0.4, 0.95, 1.0, 1.0))
	
	return ImageTexture.create_from_image(img)

static func create_engine_flame_texture() -> Texture2D:
	var img = Image.create_empty(32, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(32):
		for y in range(24):
			var dist_x = (32 - x) / 32.0
			var dist_y = abs(y - 12) / 12.0
			var factor = dist_x * (1.0 - dist_y)
			if factor > 0.1:
				var col = Color(1.0, 0.5 * factor, 0.1, factor)
				if factor > 0.6:
					col = Color(0.3, 0.8, 1.0, factor) # Plasma core
				img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)

static func create_bullet_texture() -> Texture2D:
	var img = Image.create_empty(24, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(24):
		for y in range(8):
			var alpha = (x + 1) / 24.0
			var dist_y = abs(y - 4) / 4.0
			if dist_y <= 0.8:
				var c = Color(0.2, 0.9, 1.0, alpha * (1.0 - dist_y))
				if dist_y <= 0.3:
					c = Color(1.0, 1.0, 1.0, alpha)
				img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)

static func create_missile_texture() -> Texture2D:
	var img = Image.create_empty(28, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(28):
		for y in range(12):
			var ny = abs(y - 6)
			if x >= 4 and x <= 24 and ny <= 4:
				img.set_pixel(x, y, Color(0.8, 0.2, 0.2, 1.0))
			if x >= 22 and ny <= 3:
				img.set_pixel(x, y, Color(1.0, 0.9, 0.2, 1.0))
	return ImageTexture.create_from_image(img)

static func create_enemy_basic_texture() -> Texture2D:
	var img = Image.create_empty(48, 36, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(48):
		for y in range(36):
			var ny = abs(y - 18)
			# Arrow pointing left
			var max_h = (x / 48.0) * 16.0
			if ny <= max_h:
				img.set_pixel(x, y, Color(0.8, 0.15, 0.25, 1.0))
			if x >= 10 and x <= 25 and ny <= 4:
				img.set_pixel(x, y, Color(1.0, 0.4, 0.1, 1.0))
	return ImageTexture.create_from_image(img)

static func create_enemy_shooter_texture() -> Texture2D:
	var img = Image.create_empty(44, 44, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var center = Vector2(22, 22)
	for x in range(44):
		for y in range(44):
			var d = center.distance_to(Vector2(x, y))
			if d <= 20:
				img.set_pixel(x, y, Color(0.5, 0.1, 0.7, 1.0))
			if d <= 8:
				img.set_pixel(x, y, Color(1.0, 0.2, 0.3, 1.0)) # Red optical core
	return ImageTexture.create_from_image(img)

static func create_enemy_kamikaze_texture() -> Texture2D:
	var img = Image.create_empty(36, 36, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(36):
		for y in range(36):
			var ny = abs(y - 18)
			if ny <= (x / 36.0) * 14.0:
				img.set_pixel(x, y, Color(0.9, 0.8, 0.1, 1.0))
			if x <= 10 and ny <= 2:
				img.set_pixel(x, y, Color(1.0, 0.2, 0.1, 1.0)) # Plasma tip
	return ImageTexture.create_from_image(img)

static func create_boss_texture() -> Texture2D:
	var img = Image.create_empty(120, 100, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(120):
		for y in range(100):
			var ny = abs(y - 50)
			if x >= 10 and x <= 110 and ny <= 45:
				img.set_pixel(x, y, Color(0.3, 0.1, 0.4, 1.0))
			if x <= 40 and ny <= 30:
				img.set_pixel(x, y, Color(0.6, 0.1, 0.2, 1.0))
			if x >= 40 and x <= 80 and ny <= 15:
				img.set_pixel(x, y, Color(0.9, 0.7, 0.1, 1.0)) # Energy reactor
	return ImageTexture.create_from_image(img)

static func create_asteroid_texture(size_px: int = 48) -> Texture2D:
	var img = Image.create_empty(size_px, size_px, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var radius = size_px * 0.45
	var center = Vector2(size_px / 2.0, size_px / 2.0)
	for x in range(size_px):
		for y in range(size_px):
			var pos = Vector2(x, y)
			var d = pos.distance_to(center)
			# Irregular rocky boundary using pseudo-noise
			var noise_val = sin(pos.x * 0.3) * cos(pos.y * 0.3) * 4.0
			if d <= (radius + noise_val):
				var shade = 0.35 + (0.25 * (1.0 - d / radius))
				img.set_pixel(x, y, Color(shade, shade * 0.9, shade * 0.8, 1.0))
	return ImageTexture.create_from_image(img)

static func create_powerup_texture(color: Color) -> Texture2D:
	var img = Image.create_empty(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var center = Vector2(16, 16)
	for x in range(32):
		for y in range(32):
			var d = center.distance_to(Vector2(x, y))
			if d <= 14:
				var alpha = 1.0 if d <= 12 else (14 - d) / 2.0
				img.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
			if d <= 6:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.9))
	return ImageTexture.create_from_image(img)

static func create_particle_texture() -> Texture2D:
	var img = Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var center = Vector2(8, 8)
	for x in range(16):
		for y in range(16):
			var d = center.distance_to(Vector2(x, y))
			if d <= 7:
				var alpha = (7.0 - d) / 7.0
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(img)
