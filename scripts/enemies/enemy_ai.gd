extends CharacterBody2D
# ============================================================
# EnemyAI – Skelett-Ritter Gegner
#
# Zustände:
#   PATROUILLE → läuft zwischen zwei Punkten hin und her
#   VERFOLGEN  → rennt auf den Spieler zu (Sichtweite 200px)
#   ANGRIFF    → trifft den Spieler (Angriffsweite 60px)
#   TOT        → queue_free() wird aufgerufen
#
# HP-Balken wird via _draw() direkt gezeichnet (kein extra Node nötig).
# ============================================================

const SCHWERKRAFT      := 980.0
const LAUF_SPEED       := 150.0
const PATROUILLE_DIST  := 300.0
const SICHT_WEITE      := 200.0
const ANGRIFF_WEITE    :=  60.0
const RUECK_WEITE      := 400.0
const ANGRIFF_PAUSE    :=   1.5  # Sekunden zwischen zwei Angriffen
const MAX_HP           :=   3

enum Zustand { PATROUILLE, VERFOLGEN, ANGRIFF, TOT }

var hp:            int      = MAX_HP
var zustand:       Zustand  = Zustand.PATROUILLE
var richtung:      float    = 1.0   # +1 = rechts, -1 = links
var start_x:       float    = 0.0
var patrouille_ziel: float  = 0.0
var angriff_timer: float    = 0.0

var spieler: CharacterBody2D = null

@onready var sprite:       Sprite2D  = $Sprite2D
@onready var kanten_check: RayCast2D = $KantenCheck


func _ready() -> void:
	add_to_group("gegner")
	start_x          = global_position.x
	patrouille_ziel   = start_x + PATROUILLE_DIST
	call_deferred("_suche_spieler")


func _suche_spieler() -> void:
	spieler = get_tree().get_first_node_in_group("spieler")


func _physics_process(delta: float) -> void:
	if zustand == Zustand.TOT:
		return

	# Schwerkraft
	if not is_on_floor():
		velocity.y += SCHWERKRAFT * delta

	# Angriffs-Cooldown herunter zählen
	if angriff_timer > 0.0:
		angriff_timer -= delta

	# Abstand zum Spieler
	var abstand := INF
	if spieler:
		abstand = global_position.distance_to(spieler.global_position)

	# ── Zustandsmaschine ──────────────────────────────────────
	match zustand:
		Zustand.PATROUILLE:
			_patrouilliere()
			if abstand < SICHT_WEITE:
				zustand = Zustand.VERFOLGEN

		Zustand.VERFOLGEN:
			_verfolge_spieler()
			if abstand <= ANGRIFF_WEITE:
				zustand = Zustand.ANGRIFF
			elif abstand > RUECK_WEITE:
				zustand = Zustand.PATROUILLE
				patrouille_ziel = start_x + PATROUILLE_DIST * richtung

		Zustand.ANGRIFF:
			velocity.x = 0.0
			if abstand > ANGRIFF_WEITE:
				zustand = Zustand.VERFOLGEN
			elif angriff_timer <= 0.0:
				_greife_an()

	# Sprite spiegeln je nach Bewegungsrichtung
	if velocity.x < -5.0:
		sprite.flip_h = true
	elif velocity.x > 5.0:
		sprite.flip_h = false

	move_and_slide()

	# Gegen Wand gelaufen → umdrehen
	if is_on_wall():
		richtung *= -1.0
		patrouille_ziel = global_position.x + PATROUILLE_DIST * richtung

	# HP-Balken neu zeichnen
	queue_redraw()


func _patrouilliere() -> void:
	# Plattformkante prüfen: RayCast zeigt in Gehrichtung schräg nach unten
	kanten_check.position.x = 28.0 * richtung
	kanten_check.force_raycast_update()

	var am_ziel:     bool = abs(patrouille_ziel - global_position.x) < 8.0
	var keine_kante: bool = not kanten_check.is_colliding()

	if am_ziel or keine_kante:
		richtung        *= -1.0
		patrouille_ziel  = global_position.x + PATROUILLE_DIST * richtung

	velocity.x = richtung * LAUF_SPEED


func _verfolge_spieler() -> void:
	if not spieler:
		return
	var dx := spieler.global_position.x - global_position.x
	velocity.x = sign(dx) * LAUF_SPEED


func _greife_an() -> void:
	angriff_timer = ANGRIFF_PAUSE
	if spieler and global_position.distance_to(spieler.global_position) <= ANGRIFF_WEITE:
		if spieler.has_method("schaden_nehmen"):
			spieler.schaden_nehmen(1)


# ============================================================
# Schaden nehmen (wird vom Spieler aufgerufen)
# ============================================================
func schaden_nehmen(menge: int) -> void:
	if zustand == Zustand.TOT:
		return
	hp = max(hp - menge, 0)
	queue_redraw()
	if hp <= 0:
		_sterben()


func _sterben() -> void:
	zustand = Zustand.TOT
	queue_free()


# ============================================================
# HP-Balken direkt über dem Sprite zeichnen
# ============================================================
func _draw() -> void:
	if zustand == Zustand.TOT:
		return
	const BREITE := 50.0
	const HOEHE  :=  6.0
	var x := -BREITE / 2.0
	var y := -65.0          # oberhalb des Sprites

	# Hintergrund (dunkelrot)
	draw_rect(Rect2(x, y, BREITE, HOEHE), Color(0.25, 0.0, 0.0))
	# Füllung (hellrot, proportional zu HP)
	var fuellung := BREITE * (float(hp) / float(MAX_HP))
	if fuellung > 0.0:
		draw_rect(Rect2(x, y, fuellung, HOEHE), Color(0.90, 0.10, 0.10))
	# Pixel-Art Rahmen (1px dunkel)
	draw_rect(Rect2(x, y, BREITE, HOEHE), Color(0.0, 0.0, 0.0, 0.6), false)
