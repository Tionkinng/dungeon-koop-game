extends CanvasLayer
# ============================================================
# MobileControls – Touch-Joystick + runde Action-Buttons
#
# Architektur:
#   CanvasLayer
#   └─ Bildschirm (Control, FULL_RECT)
#       ├─ JoyBasis  (Panel, Kreis, PRESET_BOTTOM_LEFT)
#       │   └─ JoyStick (Panel, Kreis, frei positioniert)
#       ├─ BtnSprung  (Panel, Kreis, PRESET_BOTTOM_RIGHT)
#       ├─ BtnAngriff (Panel, Kreis, PRESET_BOTTOM_RIGHT)
#       └─ BtnInterakt(Panel, Kreis, PRESET_BOTTOM_RIGHT)
#
# Positionierung der kleinen Buttons:
#   Mittelpunkt Sprung-Button + Winkelversatz (Grad, CCW von rechts)
#   Angriff  → 210° / 160px → 10-Uhr-Position
#   Interakt → 240° / 160px → 11-Uhr-Position
# ============================================================

# --- Spieler-Referenz (wird per Gruppe gesucht) ---
var spieler: CharacterBody2D = null

# --- Joystick ---
var _joy_basis:    Panel
var _joy_stick:    Panel
var _joy_touch_id: int    = -1
var _joy_start:    Vector2 = Vector2.ZERO

const JOY_GROESSE    := 160.0   # Durchmesser der Basis
const STICK_GROESSE  := 60.0    # Durchmesser des Sticks
const JOY_MAX_AUST   := 50.0    # Max. Stick-Auslenkung in Pixeln
const TOT_ZONE       := 0.20    # 20 % Totzone

# --- Pause-Button ---
var _btn_pause: Button

# --- Action-Buttons ---
var _btn_sprung:   Panel
var _btn_angriff:  Panel
var _btn_interakt: Panel

var _sprung_touch_id:   int = -1
var _angriff_touch_id:  int = -1
var _interakt_touch_id: int = -1

const BTN_SPRUNG_D  := 130.0   # Durchmesser Sprung-Button
const BTN_KLEIN_D   := 90.0    # Durchmesser Angriff / Interakt
const BTN_ABSTAND   := 160.0   # Abstand kl. Buttons vom Sprung-Mittelpunkt

# --- Farben ---
const FARBE_JOY_BASIS := Color(0.12, 0.12, 0.14, 0.55)
const FARBE_JOY_STICK := Color(0.55, 0.55, 0.60, 0.75)
const FARBE_SPRUNG    := Color(0.12, 0.55, 0.18, 0.55)
const FARBE_ANGRIFF   := Color(0.65, 0.18, 0.08, 0.55)
const FARBE_INTERAKT  := Color(0.15, 0.35, 0.65, 0.55)


# ============================================================
func _ready() -> void:
	layer = 10

	# Wurzel-Control: füllt den gesamten Bildschirm.
	# Alle Kind-Controls ankern sich daran – nicht am CanvasLayer.
	var bildschirm := Control.new()
	bildschirm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bildschirm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bildschirm)

	_baue_joystick(bildschirm)
	_baue_action_buttons(bildschirm)
	_baue_pause_button(bildschirm)
	call_deferred("_suche_spieler")


# ============================================================
# Pause-Button (oben links, 60x60)
# process_mode = ALWAYS damit er auch während Pause reagiert
# ============================================================
func _baue_pause_button(bildschirm: Control) -> void:
	_btn_pause = Button.new()
	_btn_pause.text = "☰"
	_btn_pause.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_btn_pause.offset_left   = 20.0
	_btn_pause.offset_top    = 20.0
	_btn_pause.offset_right  = 80.0
	_btn_pause.offset_bottom = 80.0
	_btn_pause.process_mode  = PROCESS_MODE_ALWAYS

	# Halb-transparenter runder Hintergrund (Pixel-Art)
	var s := _pause_style(Color(0.12, 0.12, 0.14, 0.55))
	var s_hover    := _pause_style(Color(0.25, 0.25, 0.28, 0.75))
	var s_pressed  := _pause_style(Color(0.40, 0.40, 0.43, 0.90))
	var s_focus    := StyleBoxFlat.new()
	s_focus.draw_center = false

	_btn_pause.add_theme_stylebox_override("normal",  s)
	_btn_pause.add_theme_stylebox_override("hover",   s_hover)
	_btn_pause.add_theme_stylebox_override("pressed", s_pressed)
	_btn_pause.add_theme_stylebox_override("focus",   s_focus)
	_btn_pause.add_theme_font_size_override("font_size", 28)
	_btn_pause.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.85))

	bildschirm.add_child(_btn_pause)
	_btn_pause.pressed.connect(_on_pause_gedrueckt)


func _pause_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	# Abgerundete Ecken (30 = halbe Größe → Kreis-Effekt)
	s.corner_radius_top_left     = 30
	s.corner_radius_top_right    = 30
	s.corner_radius_bottom_left  = 30
	s.corner_radius_bottom_right = 30
	s.corner_detail   = 8
	s.border_width_left = 0; s.border_width_top    = 0
	s.border_width_right = 0; s.border_width_bottom = 0
	return s


func _on_pause_gedrueckt() -> void:
	var pm: Node = get_tree().get_first_node_in_group("pause_menu")
	if pm == null:
		return
	if get_tree().paused:
		pm.schliessen()
	else:
		pm.oeffnen()


func _suche_spieler() -> void:
	spieler = get_tree().get_first_node_in_group("spieler")


# ============================================================
# Joystick (unten links, 100px vom Rand)
# ============================================================
func _baue_joystick(eltern: Control) -> void:
	# Basis: PRESET_BOTTOM_LEFT → Anker links-unten (0, 1)
	_joy_basis = _kreis_panel(FARBE_JOY_BASIS, JOY_GROESSE, 16)
	_joy_basis.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_joy_basis.offset_left   =  20.0
	_joy_basis.offset_right  =  20.0 + JOY_GROESSE
	_joy_basis.offset_bottom = -20.0
	_joy_basis.offset_top    = -20.0 - JOY_GROESSE
	eltern.add_child(_joy_basis)

	# Stick: Kind der Basis, wird per position verschoben (kein Anker-Preset)
	_joy_stick = _kreis_panel(FARBE_JOY_STICK, STICK_GROESSE, 16)
	_joy_stick.size     = Vector2(STICK_GROESSE, STICK_GROESSE)
	_joy_stick.position = _stick_mitte_pos()
	_joy_basis.add_child(_joy_stick)


# ============================================================
# Sprung-, Angriff- und Interakt-Button (unten rechts)
#
# Koordinatensystem für Winkelberechnung:
#   0°   = rechts  (+x)
#   90°  = unten   (+y, da Bildschirm-Y nach unten zeigt)
#   180° = links   (−x)
#   270° = oben    (−y)
#
# In Godot gilt: sin(210°) < 0  →  dy < 0  →  visuelle Aufwärtsbewegung ✓
# ============================================================
func _baue_action_buttons(eltern: Control) -> void:
	# Sprung: 130×130, 60px vom rechten / unteren Rand
	# Mittelpunkt-Offset vom BR-Anker: (−125, −125)
	var sm_r := -60.0 - BTN_SPRUNG_D / 2.0   # = -125  (von rechts)
	var sm_b := -60.0 - BTN_SPRUNG_D / 2.0   # = -125  (von unten)

	_btn_sprung = _kreis_panel(FARBE_SPRUNG, BTN_SPRUNG_D, 16)
	_btn_sprung.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_btn_sprung.offset_right  = -60.0
	_btn_sprung.offset_bottom = -60.0
	_btn_sprung.offset_left   = -60.0 - BTN_SPRUNG_D
	_btn_sprung.offset_top    = -60.0 - BTN_SPRUNG_D
	_label(_btn_sprung, "▲\nSPRUNG", 14)
	eltern.add_child(_btn_sprung)

	# Direkte Pixel-Offsets relativ zum Sprung-Mittelpunkt (sm_r, sm_b).
	# Abstände vom Sprung-Mittelpunkt (Bildschirm-Y zeigt nach unten → negativ = nach oben):
	#
	# Angriff (A):  120 px links,  40 px höher  → liegt seitlich neben dem Sprung-Button
	# Interakt (E):  40 px links, 120 px höher  → liegt direkt über dem Sprung-Button
	#
	# Abstand A→Sprung:  √(120²+40²) ≈ 126 px  → Lücke zum Rand: 126−(65+45) ≈ 16 px
	# Abstand E→Sprung:  √(40²+120²) ≈ 126 px  → Lücke zum Rand: 126−(65+45) ≈ 16 px
	# Abstand A→E:       √(80²+80²)  ≈ 113 px  → Lücke zwischen Rändern:       113−90 ≈ 23 px
	var halb := BTN_KLEIN_D / 2.0

	# Angriff: 120 px links, 40 px höher (seitlich neben Sprung)
	var dx_a := -120.0
	var dy_a :=  -40.0

	_btn_angriff = _kreis_panel(FARBE_ANGRIFF, BTN_KLEIN_D, 12)
	_btn_angriff.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_btn_angriff.offset_left   = sm_r + dx_a - halb
	_btn_angriff.offset_right  = sm_r + dx_a + halb
	_btn_angriff.offset_top    = sm_b + dy_a - halb
	_btn_angriff.offset_bottom = sm_b + dy_a + halb
	_label(_btn_angriff, "⚔\nA", 16)
	eltern.add_child(_btn_angriff)

	# Interakt: 40 px links, 120 px höher (direkt über Sprung)
	var dx_i :=  -40.0
	var dy_i := -120.0

	_btn_interakt = _kreis_panel(FARBE_INTERAKT, BTN_KLEIN_D, 12)
	_btn_interakt.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_btn_interakt.offset_left   = sm_r + dx_i - halb
	_btn_interakt.offset_right  = sm_r + dx_i + halb
	_btn_interakt.offset_top    = sm_b + dy_i - halb
	_btn_interakt.offset_bottom = sm_b + dy_i + halb
	_label(_btn_interakt, "✋\nE", 16)
	eltern.add_child(_btn_interakt)


# ============================================================
# Hilfsfunktionen
# ============================================================

# Erstellt ein Panel mit kreisförmiger StyleBoxFlat.
# corner_radius = halbe Größe → visuell perfekter Kreis.
func _kreis_panel(farbe: Color, durchmesser: float, detail: int) -> Panel:
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(durchmesser, durchmesser)

	var style := StyleBoxFlat.new()
	style.bg_color = farbe
	var r := int(durchmesser / 2.0)
	style.corner_radius_top_left     = r
	style.corner_radius_top_right    = r
	style.corner_radius_bottom_left  = r
	style.corner_radius_bottom_right = r
	style.corner_detail = detail
	style.border_width_left   = 0
	style.border_width_top    = 0
	style.border_width_right  = 0
	style.border_width_bottom = 0
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _label(eltern: Panel, text: String, groesse: int) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_font_size_override("font_size", groesse)
	lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	eltern.add_child(lbl)


# Berechnet die zentrierte Ausgangsposition des Sticks innerhalb der Basis.
func _stick_mitte_pos() -> Vector2:
	return Vector2(
		(JOY_GROESSE - STICK_GROESSE) / 2.0,
		(JOY_GROESSE - STICK_GROESSE) / 2.0
	)


func _leuchte_auf(btn: Panel, an: bool) -> void:
	btn.modulate = Color(1.5, 1.5, 1.5, 1.0) if an else Color(1.0, 1.0, 1.0, 1.0)


# ============================================================
# Touch-Eingabe
# ============================================================
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_begann(event.index, event.position)
		else:
			_touch_endete(event.index)
	elif event is InputEventScreenDrag and event.index == _joy_touch_id:
		_aktualisiere_stick(event.position)


func _touch_begann(id: int, pos: Vector2) -> void:
	# Kreisförmige Trefferzonen: Abstandscheck zum Mittelpunkt

	if _joy_touch_id == -1:
		var mitte := _joy_basis.get_global_rect().get_center()
		if pos.distance_to(mitte) <= JOY_GROESSE / 2.0:
			_joy_touch_id = id
			_joy_start    = mitte
			_aktualisiere_stick(pos)
			return

	if _sprung_touch_id == -1:
		var mitte := _btn_sprung.get_global_rect().get_center()
		if pos.distance_to(mitte) <= BTN_SPRUNG_D / 2.0:
			_sprung_touch_id = id
			_leuchte_auf(_btn_sprung, true)
			if spieler:
				spieler.touch_sprung = true
			return

	if _angriff_touch_id == -1:
		var mitte := _btn_angriff.get_global_rect().get_center()
		if pos.distance_to(mitte) <= BTN_KLEIN_D / 2.0:
			_angriff_touch_id = id
			_leuchte_auf(_btn_angriff, true)
			print("Angriff!")
			return

	if _interakt_touch_id == -1:
		var mitte := _btn_interakt.get_global_rect().get_center()
		if pos.distance_to(mitte) <= BTN_KLEIN_D / 2.0:
			_interakt_touch_id = id
			_leuchte_auf(_btn_interakt, true)
			print("Interaktion!")
			return


func _touch_endete(id: int) -> void:
	if id == _joy_touch_id:
		_joy_touch_id      = -1
		_joy_stick.position = _stick_mitte_pos()
		if spieler:
			spieler.touch_richtung = 0.0

	if id == _sprung_touch_id:
		_sprung_touch_id = -1
		_leuchte_auf(_btn_sprung, false)

	if id == _angriff_touch_id:
		_angriff_touch_id = -1
		_leuchte_auf(_btn_angriff, false)

	if id == _interakt_touch_id:
		_interakt_touch_id = -1
		_leuchte_auf(_btn_interakt, false)


func _aktualisiere_stick(touch_pos: Vector2) -> void:
	var delta    := touch_pos - _joy_start
	var begrenzt := delta.limit_length(JOY_MAX_AUST)

	# Stick visuell innerhalb der Basis verschieben
	_joy_stick.position = _stick_mitte_pos() + begrenzt

	# Normierte horizontale Eingabe mit Totzone
	var normiert := begrenzt / JOY_MAX_AUST
	if abs(normiert.x) < TOT_ZONE:
		normiert.x = 0.0
	if spieler:
		spieler.touch_richtung = normiert.x
