## Audio Manager - handles music and sound effects
extends Node

## Audio players
var music_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 16  # Pool of SFX players

## Volume levels (0.0 to 1.0)
var music_volume: float = 1.0
var sfx_volume: float = 1.0

## Music tracks (to be loaded when assets are added)
var music_tracks: Dictionary = {
	#"day": preload("res://assets/audio/music/day_theme.ogg"),
	#"night": preload("res://assets/audio/music/night_theme.ogg"),
	#"boss": preload("res://assets/audio/music/boss_theme.ogg"),
}

## Sound effects (to be loaded when assets are added)
var sound_effects: Dictionary = {
	#"place_structure": preload("res://assets/audio/sfx/place.ogg"),
	#"enemy_hit": preload("res://assets/audio/sfx/hit.ogg"),
	#"enemy_death": preload("res://assets/audio/sfx/death.ogg"),
}

func _ready() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	# Create SFX player pool
	for i in range(MAX_SFX_PLAYERS):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)

	# Load volume settings from SaveManager
	if SaveManager:
		music_volume = SaveManager.get_setting("music_volume", 1.0)
		sfx_volume = SaveManager.get_setting("sfx_volume", 1.0)

	print("AudioManager initialized")

func play_music(track_name: String, fade_in: float = 0.5) -> void:
	"""Play a music track with optional fade-in"""
	if not music_tracks.has(track_name):
		print("WARNING: Music track '%s' not found" % track_name)
		return

	var track = music_tracks[track_name]

	# Fade out current music
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, fade_in)
		await tween.finished

	# Set new track
	music_player.stream = track
	music_player.volume_db = linear_to_db(music_volume)
	music_player.play()

	# Fade in
	if fade_in > 0:
		music_player.volume_db = -80
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), fade_in)

func stop_music(fade_out: float = 0.5) -> void:
	"""Stop music with optional fade-out"""
	if not music_player.playing:
		return

	if fade_out > 0:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, fade_out)
		await tween.finished

	music_player.stop()

func play_sfx(sfx_name: String, volume_multiplier: float = 1.0) -> void:
	"""Play a sound effect"""
	if not sound_effects.has(sfx_name):
		# Silently skip if sound not found (for Phase 2 without audio assets)
		return

	var sfx = sound_effects[sfx_name]

	# Find available SFX player
	var player: AudioStreamPlayer = null
	for sfx_player in sfx_players:
		if not sfx_player.playing:
			player = sfx_player
			break

	if not player:
		# All players busy, use first one (will cut off)
		player = sfx_players[0]

	# Play sound
	player.stream = sfx
	player.volume_db = linear_to_db(sfx_volume * volume_multiplier)
	player.play()

func set_music_volume(volume: float) -> void:
	"""Set music volume (0.0 to 1.0)"""
	music_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume)

	# Save setting
	if SaveManager:
		SaveManager.set_setting("music_volume", music_volume)

func set_sfx_volume(volume: float) -> void:
	"""Set SFX volume (0.0 to 1.0)"""
	sfx_volume = clamp(volume, 0.0, 1.0)

	# Save setting
	if SaveManager:
		SaveManager.set_setting("sfx_volume", sfx_volume)

func linear_to_db(linear: float) -> float:
	"""Convert linear volume (0-1) to decibels"""
	if linear <= 0:
		return -80
	return 20 * log(linear) / log(10)
