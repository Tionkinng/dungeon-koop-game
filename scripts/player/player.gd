extends CharacterBody2D
# ============================================================
# Player – Spieler-Steuerung (Spieler 1 & Spieler 2)
# ============================================================
# Zuständig für:
#   - Bewegung (Laufen, Springen, Doppelsprung)
#   - Angriffe (Nahkampf, Spezialangriff)
#   - Lebenspunkte, Schaden nehmen und Tod
#   - Animationen über AnimatedSprite2D
#   - Koop-Interaktionen (Spieler heben, wiederbeleben)
#   - Netzwerk-Synchronisation via NetworkManager
# ============================================================

# --- Einstellungen (im Inspektor anpassbar) ---
@export var spieler_id:        int   = 1       # 1 oder 2
@export var bewegungs_speed:   float = 280.0
@export var sprung_kraft:      float = -520.0
@export var max_lebenspunkte:  int   = 100

# --- Schwerkraft ---
# Standardwert aus den Projekteinstellungen übernehmen
var schwerkraft: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- Zustand ---
var lebenspunkte:        int  = max_lebenspunkte
var ist_tot:             bool = false
var doppelsprung_bereit: bool = false
var ist_auf_boden:       bool = false

# --- Node-Referenzen ---
@onready var sprite:    AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox:    Area2D           = $Hitbox
@onready var hurtbox:   Area2D           = $Hurtbox


# --- Godot Lifecycle ---

func _ready() -> void:
	pass # TODO: Spieler-ID zuweisen, Startanimation, Netzwerk-Autorität setzen

func _physics_process(delta: float) -> void:
	pass # TODO: Schwerkraft anwenden → Eingabe lesen → move_and_slide()

func _process(_delta: float) -> void:
	pass # TODO: Animationszustand aktualisieren


# --- Bewegung ---

func _verarbeite_eingabe() -> void:
	pass # TODO: Input.get_axis("links","rechts") → velocity.x setzen

func _verarbeite_sprung() -> void:
	pass # TODO: Sprung- und Doppelsprung-Logik


# --- Kampf ---

func angreifen() -> void:
	pass # TODO: Hitbox aktivieren → Schaden an Gegnern in Reichweite

func schaden_nehmen(menge: int, quelle: Node) -> void:
	pass # TODO: lebenspunkte reduzieren → Rückstoß → Tod prüfen

func _sterben() -> void:
	pass # TODO: Todesanimation → Wiederbelebe-Phase → NetworkManager informieren


# --- Koop ---

func wiederbeleben(von_spieler: Node) -> void:
	pass # TODO: lebenspunkte zurücksetzen → ist_tot = false → aufstehen

func trage_spieler(ziel: Node) -> void:
	pass # TODO: Ziel-Spieler als Kind anhängen → gemeinsam bewegen


# --- Netzwerk ---

func _sende_position() -> void:
	pass # TODO: NetworkManager.sync_position() mit aktueller Position aufrufen
