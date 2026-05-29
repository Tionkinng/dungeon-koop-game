extends CharacterBody2D
# ============================================================
# Player – Bewegung + Mobile Touch-Steuerung
# ============================================================

const SCHWERKRAFT       := 980.0
const LAUF_SPEED        := 300.0
const SPRUNG_KRAFT      := -550.0
const BESCHLEUNIGUNG    := 1800.0
const ABBREMSEN         := 1200.0

# Touch-Eingabe (wird von MobileControls gesetzt)
var touch_richtung: float = 0.0
var touch_sprung:   bool  = false

@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	# Schwerkraft
	if not is_on_floor():
		velocity.y += SCHWERKRAFT * delta

	# --- Horizontale Eingabe (Tastatur + Touch) ---
	var richtung := 0.0
	if Input.is_action_pressed("ui_left"):
		richtung = -1.0
	elif Input.is_action_pressed("ui_right"):
		richtung = 1.0
	# Touch überschreibt wenn aktiv
	if abs(touch_richtung) > 0.2:
		richtung = touch_richtung

	if richtung != 0.0:
		velocity.x = move_toward(velocity.x, richtung * LAUF_SPEED, BESCHLEUNIGUNG * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, ABBREMSEN * delta)

	# Sprite horizontal spiegeln je nach Laufrichtung
	if richtung < 0.0:
		sprite.flip_h = true
	elif richtung > 0.0:
		sprite.flip_h = false

	# --- Sprung ---
	var sprung_eingabe := Input.is_action_just_pressed("ui_accept") or touch_sprung
	touch_sprung = false

	if sprung_eingabe and is_on_floor():
		velocity.y = SPRUNG_KRAFT

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("angriff"):
		print("Angriff!")
	if event.is_action_pressed("interaktion"):
		print("Interaktion!")
