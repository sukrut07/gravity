class_name AudioManagerClass
extends Node

## Centralized audio manager providing rich procedural arcade SFX and audio playback.
## Generates clean retro sci-fi sounds directly in memory so audio works seamlessly out of the box.

var audio_players: Dictionary = {}
var sound_streams: Dictionary = {}

var sound_names: Array = [
	"cannon_fire", "enemy_hit", "enemy_destroy", "asteroid_hit", "asteroid_destroy",
	"player_hit", "shield_activate", "shield_hit", "powerup_pickup", "near_miss",
	"special_blast", "button_click", "game_over", "milestone", "boss_spawn"
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	generate_procedural_sounds()
	
	for s_name in sound_names:
		var asp = AudioStreamPlayer.new()
		asp.name = s_name
		if sound_streams.has(s_name):
			asp.stream = sound_streams[s_name]
		add_child(asp)
		audio_players[s_name] = asp

func play_sound(sound_name: String) -> void:
	if not SaveManager.sfx_volume > 0.01:
		return
		
	if audio_players.has(sound_name):
		var player: AudioStreamPlayer = audio_players[sound_name]
		if player.stream != null:
			# Apply pitch variation for arcade juice
			player.pitch_scale = randf_range(0.92, 1.08)
			player.volume_db = linear_to_db(SaveManager.sfx_volume)
			player.play()

func generate_procedural_sounds() -> void:
	# Laser / cannon fire: fast downward pitch sweep
	sound_streams["cannon_fire"] = _synthesize_sweep(880.0, 220.0, 0.09, 0.8)
	
	# Enemy hit: short metallic click
	sound_streams["enemy_hit"] = _synthesize_sweep(600.0, 300.0, 0.04, 0.6)
	
	# Enemy destroy / explosion: low crunch noise
	sound_streams["enemy_destroy"] = _synthesize_noise(0.22, 1.0)
	
	# Asteroid hit: dull knock
	sound_streams["asteroid_hit"] = _synthesize_sweep(240.0, 110.0, 0.06, 0.7)
	
	# Asteroid destroy: low rumble noise
	sound_streams["asteroid_destroy"] = _synthesize_noise(0.28, 0.9)
	
	# Player hit: heavy crunch
	sound_streams["player_hit"] = _synthesize_noise(0.35, 1.0)
	
	# Shield activate: rising harmonics
	sound_streams["shield_activate"] = _synthesize_sweep(320.0, 780.0, 0.22, 0.7)
	
	# Shield hit: deflected ping
	sound_streams["shield_hit"] = _synthesize_sweep(950.0, 600.0, 0.12, 0.7)
	
	# Powerup pickup: cheerful two-tone chime
	sound_streams["powerup_pickup"] = _synthesize_chime(0.25)
	
	# Near miss: quick breezy whoosh
	sound_streams["near_miss"] = _synthesize_sweep(400.0, 800.0, 0.14, 0.5)
	
	# Special blast: massive bass sweep + explosion
	sound_streams["special_blast"] = _synthesize_noise(0.55, 1.0)
	
	# Button click: high crisp blip
	sound_streams["button_click"] = _synthesize_sweep(700.0, 950.0, 0.04, 0.5)
	
	# Game over: descending minor sweep
	sound_streams["game_over"] = _synthesize_sweep(440.0, 110.0, 0.75, 0.9)
	
	# Milestone: triumphant fanfare
	sound_streams["milestone"] = _synthesize_chime(0.4)
	
	# Boss spawn: deep sinister hum
	sound_streams["boss_spawn"] = _synthesize_sweep(180.0, 80.0, 0.8, 1.0)

func _synthesize_sweep(start_freq: float, end_freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(total_samples)
	
	var phase: float = 0.0
	for i in range(total_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(total_samples)
		var freq = lerpf(start_freq, end_freq, progress)
		phase += 2.0 * PI * freq / float(sample_rate)
		
		# Envelope: linear attack, exponential decay
		var env = (1.0 - progress) * volume
		var sample_val = sin(phase) * env
		var byte_val = int(clampf((sample_val * 127.0) + 128.0, 0.0, 255.0))
		data[i] = byte_val
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _synthesize_noise(duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(total_samples)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 1337
	
	for i in range(total_samples):
		var progress = float(i) / float(total_samples)
		var env = pow(1.0 - progress, 1.8) * volume
		var noise = rng.randf_range(-1.0, 1.0) * env
		var byte_val = int(clampf((noise * 127.0) + 128.0, 0.0, 255.0))
		data[i] = byte_val
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _synthesize_chime(duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(total_samples)
	
	var phase1: float = 0.0
	var phase2: float = 0.0
	for i in range(total_samples):
		var progress = float(i) / float(total_samples)
		var freq1 = 523.25 if progress < 0.5 else 659.25 # C5 -> E5
		var freq2 = 1046.5 # Overtone
		phase1 += 2.0 * PI * freq1 / float(sample_rate)
		phase2 += 2.0 * PI * freq2 / float(sample_rate)
		
		var env = (1.0 - progress) * 0.7
		var sample_val = (sin(phase1) * 0.7 + sin(phase2) * 0.3) * env
		var byte_val = int(clampf((sample_val * 127.0) + 128.0, 0.0, 255.0))
		data[i] = byte_val
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream
