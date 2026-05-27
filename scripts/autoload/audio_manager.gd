extends Node
# ============================================================
# AudioManager – globaler Singleton für Musik und Soundeffekte
# ============================================================
# Registriert in project.godot als Autoload → überlebt Szenen-Wechsel.
# Verwendung in anderen Szenen:
#   AudioManager.play_music(load("res://..."), 2.0)
#   AudioManager.stop_music(1.0)
#   AudioManager.set_music_volume(-5.0)
# ============================================================

const SAVE_PATH = "user://settings.cfg"

var _player: AudioStreamPlayer
var _fade_tween: Tween = null

# Ziel-Lautstärke in dB – wird aus Einstellungen geladen (Standard: -10 dB)
var _ziel_lautstaerke_db: float = -10.0


func _ready() -> void:
	# Eigenen AudioStreamPlayer erstellen – lebt als Kind des Singletons
	# und wird daher nicht beim Szenenwechsel gelöscht
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)
	_lade_einstellungen()


# ============================================================
# Öffentliche API
# ============================================================

# Startet einen AudioStream mit optionalem Fade-In.
# Läuft bereits Musik, wird sie sofort abgebrochen.
# fade_in_dauer = 0.0 → kein Fade, sofort auf Ziellautstärke.
func play_music(stream: AudioStream, fade_in_dauer: float = 0.0) -> void:
	_abbrechen_fade()

	# Loop für OGG-Streams aktivieren
	if stream is AudioStreamOggVorbis:
		stream.loop = true

	_player.stream = stream
	_player.volume_db = -80.0 if fade_in_dauer > 0.0 else _ziel_lautstaerke_db
	_player.play()

	if fade_in_dauer > 0.0:
		_fade_tween = create_tween()
		_fade_tween.tween_property(_player, "volume_db", _ziel_lautstaerke_db, fade_in_dauer) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# Blendet die Musik aus und stoppt sie am Ende des Fades.
# fade_out_dauer = 0.0 → sofortiger Stopp ohne Fade.
func stop_music(fade_out_dauer: float = 0.0) -> void:
	if not _player.playing:
		return
	_abbrechen_fade()

	if fade_out_dauer <= 0.0:
		_player.stop()
		return

	_fade_tween = create_tween()
	_fade_tween.tween_property(_player, "volume_db", -80.0, fade_out_dauer) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Nach dem Fade den Player stoppen (verhindert CPU-Verbrauch bei Stille)
	_fade_tween.tween_callback(_player.stop)


# Setzt die Musiklautstärke sofort und speichert die Einstellung.
# Bereich: -80 dB (Stille) bis +6 dB (Verstärkung)
func set_music_volume(volume_db: float) -> void:
	_ziel_lautstaerke_db = clampf(volume_db, -80.0, 6.0)
	if _player.playing:
		_player.volume_db = _ziel_lautstaerke_db
	_speichere_einstellungen()


# Gibt die aktuelle Ziellautstärke zurück (für Einstellungs-UI).
func get_music_volume() -> float:
	return _ziel_lautstaerke_db


# Gibt zurück ob Musik aktuell läuft.
func is_music_playing() -> bool:
	return _player.playing


# ============================================================
# Persistenz
# ============================================================

func _speichere_einstellungen() -> void:
	var cfg := ConfigFile.new()
	# Bestehende Einstellungen laden bevor wir überschreiben
	# (damit andere Sektionen wie "language" erhalten bleiben)
	cfg.load(SAVE_PATH)
	cfg.set_value("audio", "music_volume_db", _ziel_lautstaerke_db)
	cfg.save(SAVE_PATH)


func _lade_einstellungen() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		_ziel_lautstaerke_db = cfg.get_value("audio", "music_volume_db", -10.0)


# ============================================================
# Internes
# ============================================================

func _abbrechen_fade() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null
