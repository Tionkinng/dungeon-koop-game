extends CanvasLayer
# ============================================================
# PauseMenu – Pause-Menü, Einstellungen, Bestätigungs-Dialog
#
# Texte: ALLE Beschriftungen kommen aus LanguageManager.
# Bei Sprachänderung ruft das Signal _aktualisiere_texte() auf –
# alle sichtbaren Texte ändern sich sofort ohne Neustart.
#
# Architektur (prozedural aufgebaut):
#   CanvasLayer (layer=20, ALWAYS)
#   └─ root Control (FULL_RECT)
#       ├─ _overlay    (dunkles Overlay)
#       ├─ _pause_box  (4 Buttons)
#       ├─ _einst_box  (2 Slider + Zurück)
#       └─ _best_box   (Bestätigung Ja/Nein)
# ============================================================

enum Ansicht { KEINE, PAUSE, EINSTELLUNGEN, BESTAETIGUNG }
var _ansicht: Ansicht = Ansicht.KEINE

# UI-Nodes (Struktur)
var _overlay:      ColorRect
var _pause_box:    Panel
var _einst_box:    Panel
var _best_box:     Panel
var _slider_musik: HSlider
var _slider_sfx:   HSlider

# Übersetzbare Nodes – werden in _aktualisiere_texte() befüllt
var _lbl_pause_titel:   Label
var _btn_weiterspielen: Button
var _btn_neustart:      Button
var _btn_pause_einst:   Button
var _btn_hauptmenu:     Button

var _lbl_einst_titel:   Label
var _lbl_musik:         Label
var _lbl_sfx:           Label
var _btn_zurueck:       Button

var _lbl_bestaetigung:  Label
var _btn_ja:            Button
var _btn_nein:          Button

var _tween: Tween = null


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	layer = 20
	add_to_group("pause_menu")

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.process_mode = PROCESS_MODE_ALWAYS
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color        = Color(0, 0, 0, 0)
	_overlay.visible      = false
	_overlay.process_mode = PROCESS_MODE_ALWAYS
	root.add_child(_overlay)

	_pause_box = _baue_pause_box(root)
	_einst_box = _baue_einstellungen_box(root)
	_best_box  = _baue_bestaetigung_box(root)
	_pause_box.visible = false
	_einst_box.visible = false
	_best_box.visible  = false

	# Texte initial setzen und bei Sprachänderung aktualisieren
	LanguageManager.language_changed.connect(_aktualisiere_texte)
	_aktualisiere_texte(LanguageManager.current_lang)


# ============================================================
# Texte aktualisieren (wird bei Sprachänderung aufgerufen)
# ============================================================
func _aktualisiere_texte(_lang: String = "") -> void:
	# Pause-Box
	_lbl_pause_titel.text   = "— %s —" % LanguageManager.get_text("pause_title")
	_btn_weiterspielen.text = "▶  " + LanguageManager.get_text("pause_continue")
	_btn_neustart.text      = "↺  " + LanguageManager.get_text("pause_restart")
	_btn_pause_einst.text   = "⚙  " + LanguageManager.get_text("pause_settings")
	_btn_hauptmenu.text     = "⌂  " + LanguageManager.get_text("pause_mainmenu")
	# Einstellungen-Box
	_lbl_einst_titel.text   = "— %s —" % LanguageManager.get_text("settings_title")
	_lbl_musik.text         = "🎵  " + LanguageManager.get_text("settings_music")
	_lbl_sfx.text           = "🔊  " + LanguageManager.get_text("settings_sfx")
	_btn_zurueck.text       = "←  "  + LanguageManager.get_text("settings_back")
	# Bestätigungs-Box
	_lbl_bestaetigung.text  = LanguageManager.get_text("pause_confirm")
	_btn_ja.text            = LanguageManager.get_text("confirm_yes")
	_btn_nein.text          = LanguageManager.get_text("confirm_no")


# ============================================================
# Escape-Taste: öffnen / navigieren / schließen
# ============================================================
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
	_slider_musik.value = _db_zu_percent(AudioManager.get_music_volume())
	_slider_sfx.value   = AudioManager.get_sfx_volume_percent()
	_ansicht            = Ansicht.EINSTELLUNGEN
	_pause_box.visible  = false
	_einst_box.visible  = true
	_best_box.visible   = false
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
	if mit_overlay:
		_tween.tween_property(_overlay, "color", Color(0, 0, 0, 0.65), 0.20) \
			  .from(Color(0, 0, 0, 0.0))
	_tween.tween_property(box, "modulate:a", 1.0, 0.20)


# ============================================================
# Box-Bau-Funktionen
# Jeder übersetzbare Node wird in einer Member-Variable gespeichert
# damit _aktualisiere_texte() ihn später aktualisieren kann.
# ============================================================

func _baue_pause_box(root: Control) -> Panel:
	var box := _kasten(400, 358, root)
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left   = -200.0; box.offset_right  =  200.0
	box.offset_top    = -179.0; box.offset_bottom =  179.0

	var vbox := _vbox(box, 12)
	_lbl_pause_titel   = _titel("", 32);  vbox.add_child(_lbl_pause_titel)
	vbox.add_child(_separator())
	_btn_weiterspielen = _button(""); vbox.add_child(_btn_weiterspielen)
	_btn_neustart      = _button(""); vbox.add_child(_btn_neustart)
	_btn_pause_einst   = _button(""); vbox.add_child(_btn_pause_einst)
	_btn_hauptmenu     = _button(""); vbox.add_child(_btn_hauptmenu)

	_btn_weiterspielen.pressed.connect(schliessen)
	_btn_neustart.pressed.connect(_neustart)
	_btn_pause_einst.pressed.connect(_zeige_einstellungen)
	_btn_hauptmenu.pressed.connect(_zeige_bestaetigung)
	return box


func _baue_einstellungen_box(root: Control) -> Panel:
	var box := _kasten(420, 316, root)
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left   = -210.0; box.offset_right  =  210.0
	box.offset_top    = -158.0; box.offset_bottom =  158.0

	var vbox := _vbox(box, 12)
	_lbl_einst_titel = _titel("", 24); vbox.add_child(_lbl_einst_titel)
	vbox.add_child(_separator())

	_lbl_musik = _label("", 17, HORIZONTAL_ALIGNMENT_LEFT)
	vbox.add_child(_lbl_musik)
	_slider_musik = _slider()
	_slider_musik.value_changed.connect(_on_musik_geaendert)
	vbox.add_child(_slider_musik)

	_lbl_sfx = _label("", 17, HORIZONTAL_ALIGNMENT_LEFT)
	vbox.add_child(_lbl_sfx)
	_slider_sfx = _slider()
	_slider_sfx.value_changed.connect(_on_sfx_geaendert)
	vbox.add_child(_slider_sfx)

	vbox.add_child(_separator())
	_btn_zurueck = _button("")
	_btn_zurueck.pressed.connect(_zeige_pause)
	vbox.add_child(_btn_zurueck)
	return box


func _baue_bestaetigung_box(root: Control) -> Panel:
	var box := _kasten(400, 204, root)
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left   = -200.0; box.offset_right  =  200.0
	box.offset_top    = -102.0; box.offset_bottom =  102.0

	var vbox := _vbox(box, 14)

	_lbl_bestaetigung = Label.new()
	_lbl_bestaetigung.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_bestaetigung.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
	_lbl_bestaetigung.custom_minimum_size.y = 58
	_lbl_bestaetigung.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_bestaetigung.add_theme_font_size_override("font_size", 17)
	_lbl_bestaetigung.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(_lbl_bestaetigung)
	vbox.add_child(_separator())

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_ja   = _button(""); _btn_ja.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
	_btn_nein = _button(""); _btn_nein.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_ja.pressed.connect(_zum_hauptmenu)
	_btn_nein.pressed.connect(_zeige_pause)
	hbox.add_child(_btn_ja); hbox.add_child(_btn_nein)
	vbox.add_child(hbox)
	return box


# ============================================================
# UI-Bausteine
# ============================================================

func _kasten(w: float, h: float, eltern: Control) -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(w, h)
	p.process_mode        = PROCESS_MODE_ALWAYS
	var s := StyleBoxFlat.new()
	s.bg_color            = Color(0.13, 0.13, 0.15, 0.97)
	s.border_width_left   = 4; s.border_width_top    = 4
	s.border_width_right  = 4; s.border_width_bottom = 4
	s.border_color        = Color(0.42, 0.42, 0.42, 1.0)
	s.anti_aliased        = false
	s.content_margin_left = 20; s.content_margin_right  = 20
	s.content_margin_top  = 16; s.content_margin_bottom = 16
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
	s.min_value             = 0.0; s.max_value = 100.0; s.step = 1.0
	s.custom_minimum_size   = Vector2(0, 34)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.process_mode          = PROCESS_MODE_ALWAYS
	var track := StyleBoxFlat.new()
	track.bg_color              = Color(0.15, 0.15, 0.18)
	track.content_margin_top    = 8; track.content_margin_bottom = 8
	s.add_theme_stylebox_override("slider", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color              = Color(0.28, 0.48, 0.70)
	fill.content_margin_top    = 8; fill.content_margin_bottom = 8
	s.add_theme_stylebox_override("grabber_area", fill)
	s.add_theme_constant_override("grabber_offset", 0)
	return s


func _separator() -> HSeparator:
	var sep := HSeparator.new()
	var s   := StyleBoxFlat.new()
	s.bg_color              = Color(0.4, 0.4, 0.4, 0.4)
	s.content_margin_top    = 0; s.content_margin_bottom = 0
	sep.add_theme_stylebox_override("separator", s)
	sep.custom_minimum_size.y = 2
	return sep


# ============================================================
# Lautstärke-Konvertierung: Prozent (0–100) ↔ dB
# ============================================================

func _percent_zu_db(p: float) -> float:
	return -80.0 if p <= 0.0 else linear_to_db(p / 100.0)


func _db_zu_percent(db: float) -> float:
	return clampf(db_to_linear(db) * 100.0, 0.0, 100.0)
