## ============================================================
## WICHTIGE REGEL:
## Niemals Text direkt in Szenen schreiben!
## Immer LanguageManager.get_text("schluessel") verwenden.
## Für neue Texte IMMER beide Sprachen eintragen:
##   "schluessel": {"de": "Deutsch", "en": "English"}
## ============================================================

const TEXTS: Dictionary = {

	# --- Hauptmenü ---
	"title":         {"de": "DUNGEON KOOP",                         "en": "DUNGEON COOP"},
	"subtitle":      {"de": "Ein 2-Spieler Online Koop Abenteuer",  "en": "A 2-Player Online Coop Adventure"},
	"menu_start":    {"de": "Spiel starten",                        "en": "Start Game"},
	"menu_join":     {"de": "Koop beitreten",                       "en": "Join Coop"},
	"menu_settings": {"de": "Einstellungen",                        "en": "Settings"},
	"menu_quit":     {"de": "Beenden",                              "en": "Quit"},

	# --- Pause-Menü ---
	"pause_title":    {"de": "PAUSE",        "en": "PAUSE"},
	"pause_continue": {"de": "Weiterspielen","en": "Continue"},
	"pause_restart":  {"de": "Neustart",     "en": "Restart"},
	"pause_settings": {"de": "Einstellungen","en": "Settings"},
	"pause_mainmenu": {"de": "Hauptmenü",    "en": "Main Menu"},
	"pause_confirm":  {
		"de": "Wirklich beenden?\nFortschritt wird nicht gespeichert.",
		"en": "Really quit?\nProgress will not be saved.",
	},

	# --- Einstellungen ---
	"settings_title":    {"de": "EINSTELLUNGEN", "en": "SETTINGS"},
	"settings_music":    {"de": "Musik Lautstärke", "en": "Music Volume"},
	"settings_sfx":      {"de": "Soundeffekte",     "en": "Sound Effects"},
	"settings_back":     {"de": "Zurück",            "en": "Back"},
	"settings_language": {"de": "Sprache",           "en": "Language"},

	# --- Bestätigungs-Dialog ---
	"confirm_yes": {"de": "Ja",       "en": "Yes"},
	"confirm_no":  {"de": "Abbrechen","en": "Cancel"},

	# --- Allgemein ---
	"btn_close": {"de": "Schließen", "en": "Close"},
	"btn_save":  {"de": "Speichern", "en": "Save"},
}
