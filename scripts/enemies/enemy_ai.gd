extends CharacterBody2D
# ============================================================
# EnemyAI – Skelett-Ritter Gegner
#
# Zustände:
#   PATROUILLE   → läuft 300px hin und her, dreht um an Kanten/Wänden
#   VERFOLGEN    → rennt auf den Spieler zu (Sichtweite 200px)
#   ANKUENDIGUNG → stoppt & blinkt 0.6s → Spieler kann ausweichen
#                  danach: Schaden nur wenn Spieler noch ≤60px entfernt
#                  → sofort zurück zu PATROUILLE, kein Cooldown
#   TOT          → queue_free()
# ============================================================

const SCHWERKRAFT         := 980.0
const LAUF_SPEED          := 150.0
const PATROUILLE_DIST     := 300.0
const SICHT_WEITE         := 200.0
const ANGRIFF_WEITE       :=  60.0
const RUECK_WEITE         := 400.0
const ANKUENDIGUNGS_DAUER :=   0.6   # Sekunden Vorwarnung vor dem Schlag
const MAX_HP              :=   3

enum Zustand { PATROUILLE, VERFOLGEN, ANKUENDIGUNG, TOT }

var hp:                  int     = MAX_HP
var zustand:             Zustand = Zustand.PATROUILLE
var richtung:            float   = 1.0    # +1 = rechts, -1 = links
var start_x:             float   = 0.0
var patrouille_ziel:     float   = 0.0

# Ankündigungs-Timer und Blink-Zeit
var ankuendigungs_timer: float = 0.0
var blink_zeit:          float = 0.0

var spieler: CharacterBody2D = null

@onready var sprite:       Sprite2D  = $Sprite2D
@onready var kanten_check: RayCast2D = $KantenCheck


func _ready() -> void:
	add_to_group("gegner")
	start_x         = global_position.x
	patrouille_ziel = start_x + PATROUILLE_DIST
	call_deferred("_suche_spieler")


func _suche_spieler() -> void:
	spieler = get_tree().get_first_node_in_group("spieler")


func _physics_process(delta: float) -> void:
	if zustand == Zustand.TOT:
		return

	# Schwerkraft
	if not is_on_floor():
		velocity.y += SCHWERKRAFT * delta

	# Abstand zum Spieler berechnen
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
				# Ankündigung starten: Gegner stoppt und blinkt
				zustand             = Zustand.ANKUENDIGUNG
				ankuendigungs_timer = ANKUENDIGUNGS_DAUER
				blink_zeit          = 0.0
				velocity.x          = 0.0
			elif abstand > RUECK_WEITE:
				zustand         = Zustand.PATROUILLE
				patrouille_ziel = global_position.x + PATROUILLE_DIST * richtung

		Zustand.ANKUENDIGUNG:
			# Gegner steht still – 0.6s Vorwarnung zum Ausweichen
			velocity.x           = 0.0
			ankuendigungs_timer -= delta
			blink_zeit          += delta

			# Schnelles Blinken (8 Hz) als rote Warnung
			modulate.a = 0.35 + 0.65 * absf(sin(blink_zeit * PI * 8.0))

			if ankuendigungs_timer <= 0.0:
				# Vorwarnung abgelaufen → Angriff ausführen
				modulate.a = 1.0
				if spieler and global_position.distance_to(spieler.global_position) <= ANGRIFF_WEITE:
					# Spieler noch in Reichweite → Schaden
					if spieler.has_method("schaden_nehmen"):
						spieler.schaden_nehmen(1)
				# Sofort zurück zur Patrouille, kein Cooldown
				zustand         = Zustand.PATROUILLE
				patrouille_ziel = global_position.x + PATROUILLE_DIST * richtung

	# ── Sprite-Richtung ───────────────────────────────────────
	# flip_h=true  → schaut nach links
	# flip_h=false → schaut nach rechts
	if velocity.x < -5.0:
		sprite.flip_h = true
	elif velocity.x > 5.0:
		sprite.flip_h = false

	move_and_slide()

	# Gegen Wand gelaufen → Richtung wechseln
	if is_on_wall():
		richtung        *= -1.0
		patrouille_ziel  = global_position.x + PATROUILLE_DIST * richtung

	queue_redraw()


# ── Bewegungs-Hilfsfunktionen ─────────────────────────────────

func _patrouilliere() -> void:
	# RayCast in Gehrichtung positionieren um Plattform-Kante zu erkennen
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


# ── Kampf ─────────────────────────────────────────────────────

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


# ── HP-Balken direkt über dem Sprite zeichnen ─────────────────

func _draw() -> void:
	if zustand == Zustand.TOT:
		return
	const BREITE := 50.0
	const HOEHE  :=  6.0
	var x := -BREITE / 2.0
	var y := -65.0

	# Hintergrund (dunkelrot)
	draw_rect(Rect2(x, y, BREITE, HOEHE), Color(0.25, 0.0, 0.0))
	# Füllung (hellrot, proportional zu HP)
	var fuellung := BREITE * (float(hp) / float(MAX_HP))
	if fuellung > 0.0:
		draw_rect(Rect2(x, y, fuellung, HOEHE), Color(0.90, 0.10, 0.10))
	# Pixel-Art Rahmen
	draw_rect(Rect2(x, y, BREITE, HOEHE), Color(0.0, 0.0, 0.0, 0.6), false)
