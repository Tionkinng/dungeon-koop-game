extends Node
# ============================================================
# LevelGenerator – Prozeduraler Level-Generator
# ============================================================
# Zuständig für:
#   - Laden der Biom-Daten aus biomes/*.json
#   - Zufällige Raum-Generierung anhand der Biom-Parameter
#   - Platzierung von Gegnern, Schätzen und Rätseln
#   - Verbindung der Räume zu einem spielbaren Level
#   - Anpassung der Schwierigkeit je nach gewähltem Modus
#   - Bereitstellung des fertigen Level-Layouts an die Spielszene
# ============================================================

# --- Einstellungen ---
# Pfad zum Biom-Verzeichnis
const BIOME_PFAD := "res://biomes/"

# Aktuell geladene Biom-Daten (aus JSON)
var biom_daten: Dictionary = {}

# Generiertes Level-Layout (Liste von Raum-Dictionaries)
var raeume: Array = []

# Referenz auf den TileMapLayer-Node (wird von außen gesetzt)
@export var tilemap: TileMapLayer


# --- Öffentliche Methoden ---

# Biom laden und Level generieren
# biom_name: "dungeon" oder "cave"
# schwierigkeit: "leicht" | "normal" | "schwer" | "albtraum"
func generiere_level(biom_name: String, schwierigkeit: String) -> void:
	pass # TODO: JSON laden → Räume erstellen → Tiles setzen → Gegner spawnen


# Gibt alle Spawn-Positionen für Gegner zurück
func get_gegner_spawns() -> Array:
	return [] # TODO: Positionen aus raeume-Array filtern


# Gibt die Startposition beider Spieler zurück
func get_spieler_startpositionen() -> Array:
	return [] # TODO: Startposition aus dem ersten Raum ermitteln


# --- Interne Hilfsmethoden ---

func _lade_biom(biom_name: String) -> Dictionary:
	return {} # TODO: FileAccess → JSON.parse → Dictionary zurückgeben


func _erstelle_raum(config: Dictionary) -> Dictionary:
	return {} # TODO: Raum-Typ, Größe, Tile-IDs, Verbindungen definieren


func _verbinde_raeume() -> void:
	pass # TODO: Räume per Gängen oder Türen miteinander verknüpfen


func _platziere_gegner(raum: Dictionary, schwierigkeit: String) -> void:
	pass # TODO: Gegner-Instanzen anhand spawn_gewicht zufällig platzieren


func _platziere_schaetze(raum: Dictionary) -> void:
	pass # TODO: Truhen und Items zufällig in Schatz-Räumen platzieren
