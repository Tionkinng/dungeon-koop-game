extends Node
# ============================================================
# NetworkManager – Online-Koop Netzwerk-Verwaltung
# ============================================================
# Zuständig für:
#   - Erstellen und Beitreten von Online-Lobbys (Host / Client)
#   - Synchronisation der Spieler-Positionen und Zustände
#   - Weiterleitung von Spieleraktionen (Sprung, Angriff, etc.)
#   - Verwaltung von Verbindungsabbrüchen und Reconnect-Logik
#   - Ping-Anzeige und Verbindungsqualität
# ============================================================
# Godot 4 nutzt ENetMultiplayerPeer für P2P-Verbindungen.
# Für öffentliche Matches kann ein Relay-Server nötig sein.
# ============================================================

# --- Signale ---
signal spieler_verbunden(spieler_id: int)
signal spieler_getrennt(spieler_id: int)
signal verbindung_fehlgeschlagen(grund: String)
signal lobby_erstellt(lobby_code: String)

# --- Einstellungen ---
const STANDARD_PORT := 7777
const MAX_SPIELER    := 2

# Eindeutiger Lobby-Code für den aktuellen Raum
var lobby_code: String = ""

# Eigene Peer-Instanz
var peer: ENetMultiplayerPeer = null

# Zustand: "getrennt" | "host" | "client" | "verbinden"
var verbindungs_status: String = "getrennt"


# --- Öffentliche Methoden ---

# Neues Spiel hosten – gibt den Lobby-Code zurück
func hoste_spiel() -> String:
	return "" # TODO: ENetMultiplayerPeer.create_server() → lobby_code generieren

# Einem vorhandenen Spiel beitreten
func trete_bei(code: String) -> void:
	pass # TODO: IP/Port aus code ableiten → create_client() → verbinden

# Verbindung sauber trennen
func trenne() -> void:
	pass # TODO: multiplayer.multiplayer_peer = null → Status zurücksetzen


# --- Synchronisation (RPCs) ---

# Spieler-Position an alle senden (nur vom jeweiligen Spieler aufgerufen)
@rpc("any_peer", "unreliable_ordered")
func sync_position(_spieler_id: int, _position: Vector2, _richtung: int) -> void:
	pass # TODO: Position auf dem anderen Client interpolieren

# Spieler-Aktion auslösen (zuverlässig, da zustandsrelevant)
@rpc("any_peer", "reliable")
func sync_aktion(_spieler_id: int, _aktion: String, _daten: Dictionary) -> void:
	pass # TODO: Angriff / Tod / Einsammeln auf allen Clients ausführen

# Level-Seed und Biom an den Client übermitteln
@rpc("authority", "reliable")
func sync_level_start(_biom: String, _seed: int, _schwierigkeit: String) -> void:
	pass # TODO: LevelGenerator mit empfangenen Parametern starten


# --- Interne Callbacks ---

func _on_spieler_verbunden(id: int) -> void:
	pass # TODO: Spieler-Liste aktualisieren → Signal senden

func _on_spieler_getrennt(id: int) -> void:
	pass # TODO: Pause-Menü anzeigen → Reconnect-Timer starten

func _on_verbindung_fehlgeschlagen() -> void:
	pass # TODO: Fehlermeldung im UI anzeigen → Lobby schließen
