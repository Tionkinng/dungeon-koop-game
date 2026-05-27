extends Control
# ============================================================
# MainMenu – Hauptmenü Controller
# ============================================================
# Verwaltet alle Button-Aktionen und Szenenübergänge.
# Die Szene erwartet folgende Node-Struktur:
#   ButtonBereich/BtnSpielStarten
#   ButtonBereich/BtnKoopBeitreten
#   ButtonBereich/BtnEinstellungen
#   ButtonBereich/BtnBeenden
# ============================================================

# --- Node-Referenzen ---
@onready var btn_spiel_starten:  Button = $ButtonBereich/BtnSpielStarten
@onready var btn_koop_beitreten: Button = $ButtonBereich/BtnKoopBeitreten
@onready var btn_einstellungen:  Button = $ButtonBereich/BtnEinstellungen
@onready var btn_beenden:        Button = $ButtonBereich/BtnBeenden


func _ready() -> void:
	btn_spiel_starten.pressed.connect(_on_spiel_starten)
	btn_koop_beitreten.pressed.connect(_on_koop_beitreten)
	btn_einstellungen.pressed.connect(_on_einstellungen)
	btn_beenden.pressed.connect(_on_beenden)


# --- Button-Aktionen ---

func _on_spiel_starten() -> void:
	# TODO: Zur Spielszene wechseln (Solo-Modus als Host)
	# get_tree().change_scene_to_file("res://scenes/game/Game.tscn")
	pass


func _on_koop_beitreten() -> void:
	# TODO: Zur Lobby-Szene wechseln (Einladungscode eingeben)
	# get_tree().change_scene_to_file("res://scenes/ui/Lobby.tscn")
	pass


func _on_einstellungen() -> void:
	# TODO: Einstellungen-Overlay anzeigen oder Szene wechseln
	# get_tree().change_scene_to_file("res://scenes/ui/Einstellungen.tscn")
	pass


func _on_beenden() -> void:
	get_tree().quit()
