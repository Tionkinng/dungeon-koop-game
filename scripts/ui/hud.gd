extends CanvasLayer
# ============================================================
# HUD – zeigt die Spieler-Lebenspunkte als Pixel-Art Herzen
# Verbindet sich mit dem hp_geaendert Signal des Spielers.
# ============================================================

const MAX_HP := 5

var _herzen: Array[Label] = []


func _ready() -> void:
	layer = 15  # zwischen MobileControls (10) und PauseMenu (20)
	_baue_herzen()
	call_deferred("_verbinde_spieler")


func _baue_herzen() -> void:
	# Hintergrund-Panel damit Herzen gut lesbar sind
	var bg := ColorRect.new()
	bg.color    = Color(0.0, 0.0, 0.0, 0.45)
	bg.size     = Vector2(MAX_HP * 34 + 8, 40)
	bg.position = Vector2(12, 12)
	add_child(bg)

	# Herzen nebeneinander
	for i in MAX_HP:
		var lbl := Label.new()
		lbl.text     = "♥"
		lbl.position = Vector2(16 + i * 34, 12)
		lbl.add_theme_font_size_override("font_size", 26)
		lbl.add_theme_color_override("font_color", Color(0.92, 0.12, 0.12))
		add_child(lbl)
		_herzen.append(lbl)


func _verbinde_spieler() -> void:
	var spieler: Node = get_tree().get_first_node_in_group("spieler")
	if spieler and spieler.has_signal("hp_geaendert"):
		spieler.hp_geaendert.connect(_on_hp_geaendert)
		# Initialen Zustand setzen
		if "hp" in spieler:
			_on_hp_geaendert(spieler.hp)


func _on_hp_geaendert(neues_hp: int) -> void:
	for i in _herzen.size():
		var farbe := Color(0.92, 0.12, 0.12) if i < neues_hp else Color(0.30, 0.30, 0.30)
		_herzen[i].add_theme_color_override("font_color", farbe)
