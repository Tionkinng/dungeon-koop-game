extends CharacterBody2D
# ============================================================
# Player – Bewegung, Sprung, Angriff, Lebenspunkte
# ============================================================

const SCHWERKRAFT    := 980.0
const LAUF_SPEED     := 300.0
const SPRUNG_KRAFT   := -550.0
const BESCHLEUNIGUNG := 1800.0
const ABBREMSEN      := 1200.0
const MAX_HP         := 5
const ANGRIFF_RADIUS := 80.0   # Reichweite des Nahkampf-Angriffs

# Signal: wird gesendet wenn sich HP ändern (HUD hört zu)
signal hp_geaendert(neues_hp: int)

# Touch-Eingaben (werden von MobileControls gesetzt)
var touch_richtung: float = 0.0
var touch_sprung:   bool  = false
var touch_angriff:  bool  = false

# Lebenspunkte
var hp: int = MAX_HP

# Kurze Unverwundbarkeitszeit nach Treffer damit nicht jeder Frame zählt
var _schaden_timer: float = 0.0
const SCHADEN_PAUSE := 0.8

@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	# Schwerkraft
	if not is_on_floor():
		velocity.y += SCHWERKRAFT * delta

	# Schaden-Cooldown
	if _schaden_timer > 0.0:
		_schaden_timer -= delta

	# --- Horizontale Eingabe ---
	var richtung := 0.0
	if Input.is_action_pressed("ui_left"):
		richtung = -1.0
	elif Input.is_action_pressed("ui_right"):
		richtung = 1.0
	if abs(touch_richtung) > 0.2:
		richtung = touch_richtung

	if richtung != 0.0:
		velocity.x = move_toward(velocity.x, richtung * LAUF_SPEED, BESCHLEUNIGUNG * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, ABBREMSEN * delta)

	if richtung < 0.0:
		sprite.flip_h = true
	elif richtung > 0.0:
		sprite.flip_h = false

	# --- Sprung ---
	var sprung_eingabe := Input.is_action_just_pressed("ui_accept") or touch_sprung
	touch_sprung = false
	if sprung_eingabe and is_on_floor():
		velocity.y = SPRUNG_KRAFT

	# --- Angriff ---
	var angriff_eingabe := Input.is_action_just_pressed("angriff") or touch_angriff
	touch_angriff = false
	if angriff_eingabe:
		_versuche_angriff()

	move_and_slide()


# Schlägt alle Gegner innerhalb ANGRIFF_RADIUS
func _versuche_angriff() -> void:
	for gegner in get_tree().get_nodes_in_group("gegner"):
		if global_position.distance_to(gegner.global_position) <= ANGRIFF_RADIUS:
			if gegner.has_method("schaden_nehmen"):
				gegner.schaden_nehmen(1)


# Wird von Gegnern aufgerufen wenn sie angreifen
func schaden_nehmen(menge: int) -> void:
	if _schaden_timer > 0.0:
		return  # Unverwundbarkeit aktiv
	hp = max(hp - menge, 0)
	_schaden_timer = SCHADEN_PAUSE
	hp_geaendert.emit(hp)
	if hp <= 0:
		# Kurze Pause dann Level neu starten
		set_physics_process(false)
		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interaktion"):
		print("Interaktion!")
