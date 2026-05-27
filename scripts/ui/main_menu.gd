extends Control
# ============================================================
# MainMenu – Hauptmenü Controller
# ============================================================
# Node-Struktur (Pflichtknoten):
#   ButtonBereich/BtnSpielStarten
#   ButtonBereich/BtnKoopBeitreten
#   ButtonBereich/BtnEinstellungen
#   ButtonBereich/BtnBeenden
#   Untertitel
#   SprachButton
#   SprachDropdown/VBoxContainer/BtnDeutsch
#   SprachDropdown/VBoxContainer/BtnEnglish
#
# Musik: AudioManager (Autoload) besitzt den AudioStreamPlayer.
# Der Player überlebt Szenenwechsel, sodass kein eigener Node nötig ist.
# ============================================================

const MENU_MUSIK = preload("res://assets/audio/music/menu_theme.ogg")

# Flaggen-Texturen für das Kugel-Overlay (Schlüssel = Sprachcode)
const FLAGGEN: Dictionary = {
	"de": preload("res://assets/ui/icons/flag_de.png"),
	"en": preload("res://assets/ui/icons/flag_en.png"),
}

# --- Menü-Buttons ---
@onready var btn_spiel_starten:  Button = $ButtonBereich/BtnSpielStarten
@onready var btn_koop_beitreten: Button = $ButtonBereich/BtnKoopBeitreten
@onready var btn_einstellungen:  Button = $ButtonBereich/BtnEinstellungen
@onready var btn_beenden:        Button = $ButtonBereich/BtnBeenden
@onready var untertitel:         Label  = $Untertitel

# --- Sprachauswahl ---
@onready var sprach_button:   TextureButton = $SprachButton
@onready var flagge_anzeige:  TextureRect   = $SprachButton/FlaggeAnzeige
@onready var sprach_dropdown: Panel         = $SprachDropdown
@onready var btn_deutsch:     Button        = $SprachDropdown/VBoxContainer/BtnDeutsch
@onready var btn_english:     Button        = $SprachDropdown/VBoxContainer/BtnEnglish


func _ready() -> void:
	# Menü-Buttons verdrahten
	btn_spiel_starten.pressed.connect(_on_spiel_starten)
	btn_koop_beitreten.pressed.connect(_on_koop_beitreten)
	btn_einstellungen.pressed.connect(_on_einstellungen)
	btn_beenden.pressed.connect(_on_beenden)

	# Sprachauswahl verdrahten
	sprach_button.pressed.connect(_on_sprach_button_gedrueckt)
	btn_deutsch.pressed.connect(func(): _waehle_sprache("de"))
	btn_english.pressed.connect(func(): _waehle_sprache("en"))

	# Auf Sprachänderungen vom Singleton reagieren
	LanguageManager.language_changed.connect(_aktualisiere_texte)

	# Texte beim Start setzen (gespeicherte Sprache anwenden)
	_aktualisiere_texte(LanguageManager.current_lang)

	# Hintergrundmusik mit 2-Sekunden Fade-In starten
	AudioManager.play_music(MENU_MUSIK, 2.0)


# Alle übersetzbaren Texte im Menü neu setzen.
func _aktualisiere_texte(_lang: String) -> void:
	btn_spiel_starten.text  = LanguageManager.get_text("menu_start")
	btn_koop_beitreten.text = LanguageManager.get_text("menu_join")
	btn_einstellungen.text  = LanguageManager.get_text("menu_settings")
	btn_beenden.text        = LanguageManager.get_text("menu_quit")
	untertitel.text         = LanguageManager.get_text("subtitle")
	# Titel "DUNGEON KOOP" bleibt sprachunabhängig

	# Flagge auf der Weltkugel aktualisieren
	var flagge = FLAGGEN.get(LanguageManager.current_lang)
	if flagge:
		flagge_anzeige.texture = flagge


# --- Sprachauswahl ---

func _on_sprach_button_gedrueckt() -> void:
	sprach_dropdown.visible = not sprach_dropdown.visible


func _waehle_sprache(lang: String) -> void:
	LanguageManager.set_language(lang)
	sprach_dropdown.visible = false


# Dropdown schließen wenn außerhalb geklickt wird.
func _input(event: InputEvent) -> void:
	if not sprach_dropdown.visible:
		return
	if event is InputEventMouseButton and event.pressed:
		if not sprach_dropdown.get_global_rect().has_point(event.global_position):
			sprach_dropdown.visible = false


# --- Menü-Aktionen ---

func _on_spiel_starten() -> void:
	# Buttons sperren damit kein Doppelklick möglich ist
	btn_spiel_starten.disabled = true

	# Musik 1 Sekunde lang ausblenden, danach Szene wechseln
	AudioManager.stop_music(1.0)
	await get_tree().create_timer(1.0).timeout
	# TODO: get_tree().change_scene_to_file("res://scenes/game/Game.tscn")

	# Placeholder: Button wieder freigeben bis Spielszene existiert
	btn_spiel_starten.disabled = false


func _on_koop_beitreten() -> void:
	# TODO: get_tree().change_scene_to_file("res://scenes/ui/Lobby.tscn")
	pass


func _on_einstellungen() -> void:
	# TODO: get_tree().change_scene_to_file("res://scenes/ui/Einstellungen.tscn")
	pass


func _on_beenden() -> void:
	get_tree().quit()
