class_name ShipData
extends RefCounted

## Catalog and configuration data for playable starships in Gravity: Endless Flight.

static func get_all_ships() -> Array[Dictionary]:
	return [
		{
			"id": "viper",
			"name": "VIPER-01",
			"role": "FEDERATION STRIKER",
			"desc": "Standard-issue federation fighter. Perfectly balanced agility, dual plasma spread, and rapid shield recovery.",
			"straight": "res://SpaceRage/Player/player_b_m.png",
			"up_1": "res://SpaceRage/Player/player_b_l1.png",
			"up_2": "res://SpaceRage/Player/player_b_l2.png",
			"down_1": "res://SpaceRage/Player/player_b_r1.png",
			"down_2": "res://SpaceRage/Player/player_b_r2.png",
			"shadow": "res://SpaceRage/Shadows/player_shadow_m.png",
			"trail_color": Color(0.2, 0.85, 1.0, 0.75),
			"bullet_color": Color(0.2, 0.9, 1.0, 1.0),
			"accent_color": Color(0.2, 0.85, 1.0, 1.0),
			"speed_mod": 1.0,
			"turn_mod": 1.0,
			"fire_rate_mod": 1.0,
			"stat_speed": 75,
			"stat_handling": 80,
			"stat_firepower": 75,
			"stat_shield": 80
		},
		{
			"id": "crimson",
			"name": "CRIMSON FURY",
			"role": "ASSAULT INTERCEPTOR",
			"desc": "Overclocked twin-turbines with hyper-charged vulcan cannons. Sacrifices shield recharge for blazing offensive power.",
			"straight": "res://SpaceRage/Player/player_r_m.png",
			"up_1": "res://SpaceRage/Player/player_r_l1.png",
			"up_2": "res://SpaceRage/Player/player_r_l2.png",
			"down_1": "res://SpaceRage/Player/player_r_r1.png",
			"down_2": "res://SpaceRage/Player/player_r_r2.png",
			"shadow": "res://SpaceRage/Shadows/player_shadow_m.png",
			"trail_color": Color(1.0, 0.35, 0.15, 0.8),
			"bullet_color": Color(1.0, 0.35, 0.2, 1.0),
			"accent_color": Color(1.0, 0.3, 0.2, 1.0),
			"speed_mod": 1.08,
			"turn_mod": 0.95,
			"fire_rate_mod": 0.88, # 12% faster rate of fire
			"stat_speed": 85,
			"stat_handling": 70,
			"stat_firepower": 95,
			"stat_shield": 65
		},
		{
			"id": "emerald",
			"name": "EMERALD PHANTOM",
			"role": "AGILE RECON SCOUT",
			"desc": "Ultra-lightweight aerodynamic frame with ion micro-thrusters. Dances effortlessly through high-density asteroid belts.",
			"straight": "res://SpaceRage/Enemies/enemy_1_g_m.png",
			"up_1": "res://SpaceRage/Enemies/enemy_1_g_l1.png",
			"up_2": "res://SpaceRage/Enemies/enemy_1_g_l2.png",
			"down_1": "res://SpaceRage/Enemies/enemy_1_g_r1.png",
			"down_2": "res://SpaceRage/Enemies/enemy_1_g_r2.png",
			"shadow": "res://SpaceRage/Shadows/enemy_1_shadow_m.png",
			"trail_color": Color(0.2, 1.0, 0.45, 0.8),
			"bullet_color": Color(0.25, 1.0, 0.5, 1.0),
			"accent_color": Color(0.2, 1.0, 0.45, 1.0),
			"speed_mod": 1.15,
			"turn_mod": 1.20,
			"fire_rate_mod": 1.0,
			"stat_speed": 95,
			"stat_handling": 100,
			"stat_firepower": 70,
			"stat_shield": 70
		},
		{
			"id": "phoenix",
			"name": "SOLAR PHOENIX",
			"role": "HEAVY DREAD-FIGHTER",
			"desc": "Reinforced titanium blast-hull built for endurance. Generates dense electromagnetic fields for longer deflector shield uptime.",
			"straight": "res://SpaceRage/Enemies/enemy_1_r_m.png",
			"up_1": "res://SpaceRage/Enemies/enemy_1_r_l1.png",
			"up_2": "res://SpaceRage/Enemies/enemy_1_r_l2.png",
			"down_1": "res://SpaceRage/Enemies/enemy_1_r_r1.png",
			"down_2": "res://SpaceRage/Enemies/enemy_1_r_r2.png",
			"shadow": "res://SpaceRage/Shadows/enemy_1_shadow_m.png",
			"trail_color": Color(1.0, 0.75, 0.1, 0.8),
			"bullet_color": Color(1.0, 0.8, 0.15, 1.0),
			"accent_color": Color(1.0, 0.8, 0.15, 1.0),
			"speed_mod": 0.94,
			"turn_mod": 0.90,
			"fire_rate_mod": 1.05,
			"stat_speed": 65,
			"stat_handling": 65,
			"stat_firepower": 85,
			"stat_shield": 100
		},
		{
			"id": "valkyrie",
			"name": "VOID VALKYRIE",
			"role": "STEALTH PROTOTYPE",
			"desc": "Experimental dark-matter thrusters with hyper-responsive lateral micro-jets. Narrow profile excels at extreme near-miss flight.",
			"straight": "res://SpaceRage/Enemies/enemy_1_b_m.png",
			"up_1": "res://SpaceRage/Enemies/enemy_1_b_l1.png",
			"up_2": "res://SpaceRage/Enemies/enemy_1_b_l2.png",
			"down_1": "res://SpaceRage/Enemies/enemy_1_b_r1.png",
			"down_2": "res://SpaceRage/Enemies/enemy_1_b_r2.png",
			"shadow": "res://SpaceRage/Shadows/enemy_1_shadow_m.png",
			"trail_color": Color(0.65, 0.35, 1.0, 0.8),
			"bullet_color": Color(0.75, 0.4, 1.0, 1.0),
			"accent_color": Color(0.75, 0.45, 1.0, 1.0),
			"speed_mod": 1.06,
			"turn_mod": 1.10,
			"fire_rate_mod": 0.94,
			"stat_speed": 90,
			"stat_handling": 90,
			"stat_firepower": 85,
			"stat_shield": 80
		}
	]

static func get_ship_count() -> int:
	return get_all_ships().size()

static func get_ship(index: int) -> Dictionary:
	var ships = get_all_ships()
	if index >= 0 and index < ships.size():
		return ships[index]
	return ships[0]

static func create_sprite_frames_for_ship(ship_data: Dictionary) -> SpriteFrames:
	var frames = SpriteFrames.new()
	frames.add_animation("straight")
	frames.add_animation("up_1")
	frames.add_animation("up_2")
	frames.add_animation("down_1")
	frames.add_animation("down_2")
	
	var straight_tex = load(ship_data["straight"])
	var up_1_tex = load(ship_data["up_1"])
	var up_2_tex = load(ship_data["up_2"])
	var down_1_tex = load(ship_data["down_1"])
	var down_2_tex = load(ship_data["down_2"])
	
	if straight_tex: frames.add_frame("straight", straight_tex)
	if up_1_tex: frames.add_frame("up_1", up_1_tex)
	if up_2_tex: frames.add_frame("up_2", up_2_tex)
	if down_1_tex: frames.add_frame("down_1", down_1_tex)
	if down_2_tex: frames.add_frame("down_2", down_2_tex)
	
	return frames
