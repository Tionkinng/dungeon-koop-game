extends CanvasLayer
# ============================================================
# PauseMenu – Pause-Menü, Einstellungen, Bestätigungs-Dialog
#
# Architektur (prozedural aufgebaut):
#   CanvasLayer (layer=20, ALWAYS)
#   └─ root Control (FULL_RECT)
#       ├─ _overlay    (dunkles Overlay über Spielwelt)
#       ├─ _pause_box  (Haupt-Menü: 4 Buttons)
#       ├─ _einst_box  (Einstellungen: 2 Slider)
#       └─ _best_box   (Bestätigung: Ja / Abbrechen)
#
# Ablauf:
#   oeffnen()  → get_tree().paused = true  → _zeige_pause()
#   schliessen() → get_tree().paused = false → alles ausblenden
# ============================================================

enum Ansicht { KEINE, PAUSE, EINSTELLUNGEN, BESTAETIGUNG }
var _ansicht: Ansicht = Ansicht.KEINE

# UI-Nodes
var _overlay:      ColorRect
var _pause_box:    Panel
var _einst_box:    Panel
var _best_box:     Panel
var _slider_musik: HSlider
var _slider_sfx:   HSlider

var _tween: Tween = null


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 20
	add_to_group("pause_menu")

	# Vollbild-Wurzel damit Anker-Presets korrekt funktionieren
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.process_mode = PROCESS_MODE_ALWAYS
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Dunkles Overlay (startet unsichtbar)
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color   = Color(0, 0, 0, 0)
	_overlay.visible = false
	_overlay.process_mode = PROCESS_MODE_ALWAYS
	root.add_child(_overlay)

	# Alle drei Boxen aufbauen und verstecken
	_pause_box = _baue_pause_box(root)
	_einst_box = _baue_einstellungen_box(root)
	_best_box  = _baue_bestaetigung_box(root)
	_pause_box.visible = false
	_einst_box.visible = false
	_best_box.visible  = false


# Escape-Taste: Menü öffnen / navigieren / schließen
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	match _ansicht:
		Ansicht.KEINE:         oeffnen()
		Ansicht.PAUSE:         schliessen()
		Ansicht.EINSTELLUNGEN: _zeige_pause()
		Ansicht.BESTAETIGUNG:  _zeige_pause()


# ============================================================
# Öffentliche API
# ============================================================

func oeffnen() -> void:
	if _ansicht != Ansicht.KEINE:
		return
	get_tree().paused = true
	_zeige_pause()


func schliessen() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_overlay.visible   = false
	_overlay.color     = Color(0, 0, 0, 0)
	_pause_box.visible = false
	_einst_box.visible = false
	_best_box.visible  = false
	_ansicht           = Ansicht.KEINE
	get_tree().paused  = false


# ============================================================
# Ansicht-Wechsel (intern)
# ============================================================

func _zeige_pause() -> void:
	_ansicht           = Ansicht.PAUSE
	_overlay.visible   = true
	_pause_box.visible = true
	_einst_box.visible = false
	_best_box.visible  = false
	_fade_in(_pause_box, true)


func _zeige_einstellungen() -> void:
	# Aktuelle Lautstärken in Slider übertragen
	_slider_musik.value = _db_zu_percent(AudioManager.get_music_volume())
	_slider_sfx.value   = AudioManager.get_sfx_volume_percent()
	_ansicht           = Ansicht.EINSTELLUNGEN
	_pause_box.visible = false
	_einst_box.visible = true
	_best_box.visible  = false
	_fade_in(_einst_box, false)


func _zeige_bestaetigung() -> void:
	_ansicht           = Ansicht.BESTAETIGUNG
	_pause_box.visible = false
	_einst_box.visible = false
	_best_box.visible  = true
	_fade_in(_best_box, false)


# ============================================================
# Aktionen
# ============================================================

func _neustart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _zum_hauptmenu() -> void:
	# Musik ausblenden, dann erst Szene wechseln
	AudioManager.stop_music(0.5)
	await get_tree().create_timer(0.5, true).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")


func _on_musik_geaendert(wert: float) -> void:
	AudioManager.set_music_volume(_percent_zu_db(wert))


func _on_sfx_geaendert(wert: float) -> void:
	AudioManager.set_sfx_volume_percent(wert)


# ============================================================
# Fade-In Animation
# ============================================================

func _fade_in(box: Panel, mit_overlay: bool) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	box.modulate.a = 0.0
	_tween = create_tween().set_parallel(true).set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	# Overlay nur beim ersten Öffnen einblenden
	if mit_overlay:
		_tween.tween_property(_overlay, "color", Color(0, 0, 0, 0.65), 0.20) \
			  .from(Color(0, 0, 0, 0.0))
	_tween.tween_property(box, "modulate:a", 1.0, 0.20)


# ============================================================
# Box-Bau-Funktionen
# ============================================================

func _baue_pause_box(root: Control) -> Panel:
	var box := _kasten(400, 358, root)
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left   = -200.0
	box.offset_right  =  200.0
	box.offset_top    = -179.0
	box.offset_bottom =  179.0

	var vbox := _vbox(box, 12)
	vbox.add_child(_titel("— PAUSE —", 32))
	vbox.add_child(_separator())

	var b1 := _button("▶  Weiterspielen")
	var b2 := _button("↺  Neustart")
	var b3 := _button("⚙  Einstellungen")
	var b4 := _button("⌂  Hauptmenü")
	vbox.add_child(b1); vbox.add_child(b2)
	vbox.add_child(b3); vbox.add_child(b4)

	b1.pressed.connect(schliessen)
	b2.pressed.connect(_neustart)
	b3.pressed.connect(_zeige_einstellungen)
	b4.pressed.connect(_zeige_bestaetigung)
	return box


func _baue_einstellungen_box(root: Control) -> Panel:
	var box := _kasten(420, 316, root)
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left   = -210.0
	box.offset_right  =  210.0
	box.offset_top    = -158.0
	box.offset_bottom =  158.0

	var vbox := _vbox(box, 12)
	vbox.add_child(_titel("— EINSTELLUNGEN —", 24))
	vbox.add_child(_separator())
	vbox.add_child(_label("🎵  Musik Lautstärke", 17, HORIZONTAL_ALIGNMENT_LEFT))
	_slider_musik = _slider()
	_slider_musik.value_changed.connect(_on_musik_geaendert)
	vbox.add_child(_slider_musik)
	vbox.add_child(_label("🔊  Soundeffekte", 17, HORIZONTAL_ALIGNMENT_LEFT))
	_slider_sfx = _slider()
	_slider_sfx.value_changed.connect(_on_sfx_geaendert)
	vbox.add_child(_slider_sfx)
	vbox.add_child(_separator())
	var zurueck := _button("←  Zurück")
	zurueck.pressed.connect(_zeige_pause)
	vbox.add_child(zurueck)
	return box


func _baue_bestaetigung_box(root: Control) -> Panel:
	var box := _kasten(400, 204, root)
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left   = -200.0
	box.offset_right  =  200.0
	box.offset_top    = -102.0
	box.offset_bottom =  102.0

	var vbox := _vbox(box, 14)

	var txt := Label.new()
	txt.text = "Wirklich zum Hauptmenü?\nFortschritt wird nicht gespeichert."
	txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	txt.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
	txt.custom_minimum_size.y = 58
	txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	txt.add_theme_font_size_override("font_size", 17)
	txt.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(txt)
	vbox.add_child(_separator())

	# Zwei Buttons nebeneinander
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var b_ja  := _button("Ja, beenden")
	var b_nei := _button("Abbrechen")
	b_ja.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
	b_nei.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_ja.pressed.connect(_zum_hauptmenu)
	b_nei.pressed.connect(_zeige_pause)
	hbox.add_child(b_ja)
	hbox.add_child(b_nei)
	vbox.add_child(hbox)
	return box


# ============================================================
# UI-Bausteine
# ============================================================

# Panel mit Pixel-Art Rahmen (steingrau wie pixel_theme.tres)
func _kasten(w: float, h: float, eltern: Control) -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(w, h)
	p.process_mode        = PROCESS_MODE_ALWAYS
	var s := StyleBoxFlat.new()
	s.bg_color              = Color(0.13, 0.13, 0.15, 0.97)
	s.border_width_left     = 4; s.border_width_top    = 4
	s.border_width_right    = 4; s.border_width_bottom = 4
	s.border_color          = Color(0.42, 0.42, 0.42, 1.0)
	s.anti_aliased          = false
	s.content_margin_left   = 20; s.content_margin_right  = 20
	s.content_margin_top    = 16; s.content_margin_bottom = 16
	p.add_theme_stylebox_override("panel", s)
	eltern.add_child(p)
	return p


func _vbox(eltern: Panel, abstand: int) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", abstand)
	eltern.add_child(v)
	return v


func _titel(text: String, groesse: int) -> Label:
	var lbl := Label.new()
	lbl.text                  = text
	lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.custom_minimum_size.y = 48
	lbl.add_theme_font_size_override("font_size", groesse)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	return lbl


func _label(text: String, groesse: int, ausrichtung: HorizontalAlignment) -> Label:
	var lbl := Label.new()
	lbl.text                  = text
	lbl.horizontal_alignment  = ausrichtung
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", groesse)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	return lbl


# Button im Pixel-Art Stil (identisch zu pixel_theme.tres)
func _button(text: String) -> Button:
	var btn := Button.new()
	btn.text                  = text
	btn.custom_minimum_size   = Vector2(0, 56)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.process_mode          = PROCESS_MODE_ALWAYS
	btn.add_theme_stylebox_override("normal",  _btn_style(Color(0.227, 0.227, 0.227), Color(0.416, 0.416, 0.416)))
	btn.add_theme_stylebox_override("hover",   _btn_style(Color(0.353, 0.353, 0.353), Color(0.525, 0.525, 0.525)))
	btn.add_theme_stylebox_override("pressed", _btn_style(Color(0.451, 0.451, 0.451), Color(0.600, 0.600, 0.600), true))
	var kein_fokus := StyleBoxFlat.new()
	kein_fokus.draw_center = false
	btn.add_theme_stylebox_override("focus", kein_fokus)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn


func _btn_style(bg: Color, border: Color, gedrueckt: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color              = bg
	s.border_width_left     = 4; s.border_width_top    = 4
	s.border_width_right    = 4; s.border_width_bottom = 4
	s.border_color          = border
	s.anti_aliased          = false
	s.content_margin_left   = 12; s.content_margin_right  = 12
	s.content_margin_top    = 7  if gedrueckt else 4
	s.content_margin_bottom = 1  if gedrueckt else 4
	return s


func _slider() -> HSlider:
	var s := HSlider.new()
	s.min_value             = 0.0
	s.max_value             = 100.0
	s.step                  = 1.0
	s.custom_minimum_size   = Vector2(0, 34)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.process_mode          = PROCESS_MODE_ALWAYS
	var track := StyleBoxFlat.new()
	track.bg_color             = Color(0.15, 0.15, 0.18)
	track.content_margin_top   = 8
	track.content_margin_bottom = 8
	s.add_theme_stylebox_override("slider", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color              = Color(0.28, 0.48, 0.70)
	fill.content_margin_top    = 8
	fill.content_margin_bottom = 8
	s.add_theme_stylebox_override("grabber_area", fill)
	s.add_theme_constant_override("grabber_offset", 0)
	return s


func _separator() -> HSeparator:
	var sep := HSeparator.new()
	var s   := StyleBoxFlat.new()
	s.bg_color              = Color(0.4, 0.4, 0.4, 0.4)
	s.content_margin_top    = 0
	s.content_margin_bottom = 0
	sep.add_theme_stylebox_override("separator", s)
	sep.custom_minimum_size.y = 2
	return sep


# ============================================================
# Lautstärke-Konvertierung: Prozent (0–100) ↔ dB
# ============================================================

func _percent_zu_db(p: float) -> float:
	if p <= 0.0:
		return -80.0
	return linear_to_db(p / 100.0)


func _db_zu_percent(db: float) -> float:
	return clampf(db_to_linear(db) * 100.0, 0.0, 100.0)
