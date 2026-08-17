extends Node

## Centralized audio manager providing audio stream hooks for all game actions.
## Handles sound triggers gracefully even without external audio files.

var audio_players: Dictionary = {}

var sound_names: Array = [
	"cannon_fire", "enemy_hit", "enemy_destroy", "asteroid_hit", "asteroid_destroy",
	"player_hit", "shield_activate", "shield_hit", "powerup_pickup", "missile_launch",
	"boss_spawn", "boss_hit", "boss_destroy", "game_over", "button_click"
]

func _ready() -> void:
	for s_name in sound_names:
		var asp = AudioStreamPlayer.new()
		asp.name = s_name
		add_child(asp)
		audio_players[s_name] = asp

func play_sound(sound_name: String) -> void:
	if audio_players.has(sound_name):
		var player: AudioStreamPlayer = audio_players[sound_name]
		if player.stream != null:
			player.play()
		else:
			# Synthetic sound placeholder / silent safe execution
			pass
