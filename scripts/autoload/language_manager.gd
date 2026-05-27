extends Node
# ============================================================
# LanguageManager – globaler Singleton für Sprachverwaltung
# ============================================================
# Einbinden in project.godot unter [autoload]:
#   LanguageManager = "*res://scripts/autoload/language_manager.gd"
#
# Verwendung in anderen Szenen:
#   LanguageManager.get_text("menu_start")
#   LanguageManager.language_changed.connect(_on_lang_changed)
# ============================================================

const Translations = preload("res://scripts/ui/translations.gd")
const SAVE_PATH    = "user://settings.cfg"

# Signal wird bei jeder Sprachumschaltung emittiert
signal language_changed(lang_code: String)

# Aktuell aktive Sprache (Standard: Deutsch)
var current_lang: String = "de"


func _ready() -> void:
	_lade_einstellungen()


# Liefert den übersetzten Text für den gegebenen Schlüssel.
# Gibt den Schlüssel selbst zurück, wenn keine Übersetzung vorhanden.
func get_text(key: String) -> String:
	var entry: Dictionary = Translations.TEXTS.get(key, {})
	return entry.get(current_lang, key)


# Sprache umschalten und alle Listener benachrichtigen.
func set_language(lang_code: String) -> void:
	if lang_code == current_lang:
		return
	current_lang = lang_code
	_speichere_einstellungen()
	language_changed.emit(lang_code)


# --- Persistenz ---

func _speichere_einstellungen() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("language", "current", current_lang)
	cfg.save(SAVE_PATH)


func _lade_einstellungen() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		current_lang = cfg.get_value("language", "current", "de")
